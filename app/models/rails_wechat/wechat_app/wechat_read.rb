module RailsWechat::WechatApp::WechatRead
  extend ActiveSupport::Concern
  included do
  
  end

  def api
    Wechat::Api::Public.new(self)
  end

end
