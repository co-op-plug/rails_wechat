class Wechat::WechatProgramUsersController < Wechat::BaseController
  before_action :set_wechat_app, only: [:create]
  before_action :require_authorized_token, only: [:info, :mobile]
  before_action :set_wechat_program_user, only: [:info, :mobile]
  skip_before_action :verify_authenticity_token
  
  def create
    info = @wechat_app.api.jscode2session(session_params[:code])
    @wechat_program_user = WechatProgramUser.create_or_find_by!(uid: info['openid']) do |wechat_program_user|
      wechat_program_user.app_id = params[:appid]
      Rails.logger.info '+++++++++unionid'
      Rails.logger.info info
      wechat_program_user.unionid = info['unionid']
    end
    @wechat_program_user.update({unionid: info['unionid']})

    render json: { token: @wechat_program_user.auth_token(info['session_key']) }
  end

  def info
    @wechat_program_user.name = userinfo_params[:nickName]
    @wechat_program_user.avatar_url = userinfo_params[:avatarUrl]
    @wechat_program_user.extra = {
      gender: userinfo_params[:gender],
      language: userinfo_params[:language],
      city: userinfo_params[:city],
      province: userinfo_params[:province],
      country: userinfo_params[:country]
    }
    
    @wechat_program_user.save
  end

  def mobile
    session_key = current_authorized_token.session_key
    phone_number = @wechat_program_user.get_phone_number(params[:encrypted_data], params[:iv], session_key)
    r = Wechat::Cipher.program_decrypt(params[:encrypted_data], params[:iv], session_key)
    @wechat_program_user.update({unionid: r['unionId']}) # 微信返回不一致 这里返回是大写
    if phone_number
      @account = Account.find_by(identity: phone_number) || Account.create_with_identity(phone_number)

      # if @account.user.nil?
      #   wechat_user = WechatUser.find_by unionid: @wechat_program_user.unionid
      #   origin_user = wechat_user.user
      #   @wechat_program_user.user = origin_user
      #   @wechat_program_user.save
      # end

      @account.confirmed = true
      @account.join(name: @wechat_program_user.name, invited_code: params[:invited_code])

      @wechat_program_user.account = @account
      current_authorized_token.account = @account

      @wechat_program_user.save
      current_authorized_token.save

      @wechat_program_user.reload
    else
      current_authorized_token.destroy  # 触发重新授权逻辑
      render :mobile_err, locals: { model: @wechat_program_user }, status: :unprocessable_entity
    end

    # session_key = current_authorized_token.session_key
    # phone_number = @wechat_program_user.get_phone_number(params[:encrypted_data], params[:iv], session_key)
    # if phone_number
    #   @account = Account.find_by(identity: phone_number) || Account.create_with_identity(phone_number)
    #   @account.confirmed = true
    #   @account.join(name: @wechat_program_user.name, invited_code: params[:invited_code])
    #
    #   @wechat_program_user.account = @account
    #   current_authorized_token.account = @account
    #
    #   @wechat_program_user.save
    #   current_authorized_token.save
    #
    #   @wechat_program_user.reload
    # else
    #   current_authorized_token.destroy  # 触发重新授权逻辑
    #   render :mobile_err, locals: { model: @wechat_program_user }, status: :unprocessable_entity
    # end
  end

  private
  def set_wechat_app
    @wechat_app = WechatApp.find_by(appid: params[:appid])
  end
  
  def set_wechat_program_user
    @wechat_program_user = current_authorized_token.oauth_user
  end
  
  def session_params
    params.permit(
      :code,
      :encrypted_data,
      :iv
    )
  end

  def userinfo_params
    params.require(:userInfo).permit(
      :nickName,
      :gender,
      :language,
      :city,
      :province,
      :country,
      :avatarUrl
    )
  end
  
end
