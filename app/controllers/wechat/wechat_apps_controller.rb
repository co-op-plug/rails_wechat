class Wechat::WechatAppsController < Wechat::BaseController
  before_action :set_wechat_app, only: [:show]

  def show
    @oauth_user = @wechat_app.generate_wechat_user(params[:code])
    if @oauth_user.account.nil? && current_account
      @oauth_user.account = current_account
    end
    @oauth_user.save

    if @oauth_user.user
      login_by_oauth_user(@oauth_user)
      redirect_to session[:return_to] || RailsAuth.config.default_return_path, notice: 'Oauth Success!'
      session.delete :return_to
    else
      subdomain = ActionDispatch::Http::URL.extract_subdomain session[:return_to].sub(/(http|https):\/\//, ''), 1
      redirect_to sign_url(uid: @oauth_user.uid, subdomain: subdomain)
    end
  end

  def create
  end

  private
  def set_wechat_app
    @wechat_app = WechatApp.find params[:id]
  end

end