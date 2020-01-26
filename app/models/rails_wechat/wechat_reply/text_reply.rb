module RailsWechat::WechatReply::TextReply
  extend ActiveSupport::Concern
  included do
    attribute :msg_type, :string, default: 'text'
  end

  # 公众号消息类型
  # see: https://mp.weixin.qq.com/wiki?id=mp1421140543
  def content
    update(MsgType: 'text', Content: body)
  end

  def xx
    if wechat_user.user.nil?
      msg = received.app.help_without_user
    elsif wechat_user.user.disabled?
      msg = received.app.help_user_disabled
    else
      msg = wechat_request.response
    end
  end

end
