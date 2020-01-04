class Wechat::Message::Template::Program < Wechat::Message::Template


  def to_user(openid, **options)
    @message_hash.merge!(touser: openid, **options)
  end

  # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.send.html
  def do_send
    api.post 'message/subscribe/send', {}, base: API_BASE
  end

  def templates(opts = {})
    @message_hash.merge! template_id: @notice.wechat_template.template_id
    @message_hash.merge! touser: @notice.wechat_user.uid
    @message_hash.merge! data: @notice.data
  end

end
