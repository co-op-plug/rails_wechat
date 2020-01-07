# Should order after RailsAuth::Application
module RailsWechat::Application
  extend ActiveSupport::Concern

  def require_login(return_to: nil)
    return if current_user
    return super unless request.variant.any?(:wechat)
    store_location(return_to)

    if current_wechat_user && current_wechat_user.user.nil?
      redirect_url = sign_url(uid: current_wechat_user.uid)
    else
      redirect_url = '/auth/wechat'
    end

    render 'wechat_require_login', locals: { redirect_url: redirect_url, message: '请登录后操作' }, status: 401
  end

  def current_wechat_user
    return @current_wechat_user if defined?(@current_wechat_user)
    @current_wechat_user = current_authorized_token&.oauth_user
  end

  # 需要微信授权获取openid, 但并不需要注册为用户
  def require_wechat_user(return_to: nil)
    return if current_oauth_user
    store_location(return_to)

    redirect_url = '/auth/wechat?skip_register=true'

    render 'wechat_require_login', locals: { redirect_url: redirect_url, message: '请允许获取您的微信信息' }, status: 401
  end

  def bind_to_wechat(request)
    key = request[:EventKey].delete_prefix?('qrscene_')
    wechat_user = WechatUser.find_by(open_id: request[:FromUserName])
    session[:wechat_open_id] ||= request[:FromUserName]

    user = User.find_by id: key
    if wechat_user && user
      old_user = wechat_user.user
      if old_user&.id == user.id
        request.reply.text "您的微信账号已经绑定到账号 #{user.member_name} 了"
      elsif old_user
        wechat_user.update(user_id: key, state: :change_bind)
        request.reply.text "您的微信账号已更换绑定账号, 之前绑定的账号是#{old_user.member_name}, 已经绑定到#{user.member_name}"
      else
        wechat_user.update(user_id: key, state: :bind)
        request.reply.text "您的微信账号绑定至账号 #{user.member_name} 成功"
      end
    elsif user
      user.wechat_users.create(open_id: request[:FromUserName], state: :bind)
      request.reply.text "已成功绑定,账号 #{user.member_name}"
    else
      request.reply.text '未找到当前用户,绑定失败'
    end
  end

end
