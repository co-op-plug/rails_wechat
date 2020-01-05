module RailsWechat::WechatNotice
  extend ActiveSupport::Concern

  included do
    attribute :link, :string, default: 'index'

    belongs_to :notification
    belongs_to :wechat_template
    belongs_to :wechat_app
    belongs_to :wechat_user
    belongs_to :wechat_subscribed, optional: true

    before_validation do
      self.wechat_app = wechat_template.wechat_app
    end
  end

  def data
    wechat_template.data_mappings.transform_values do |key, value|
      value.merge! value: notification.notifiable_detail[value]
    end
  end

  def to_wechat
    msg = Wechat::Message::Template::Program.new(self)
    msg.do_send
  end

end
