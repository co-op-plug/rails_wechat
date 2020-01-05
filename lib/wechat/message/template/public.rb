class Wechat::Message::Template::Public < Wechat::Message::Template

  def do_send
    api.post 'message/template/send', @message_hash, base: API_BASE
  end

  def to_message
    @message_hash.merge! template_id: @notice.wechat_template.template_id
    @message_hash.merge! touser: @notice.wechat_user.uid
    @message_hash.merge! data: @notice.data
  end

end
