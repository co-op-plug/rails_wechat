module RailsWechat::WechatTemplate
  extend ActiveSupport::Concern

  included do
    attribute :template_id, :string
    attribute :title, :string
    attribute :content, :string
    attribute :example, :string
    attribute :template_type, :integer

    belongs_to :wechat_app
    belongs_to :template_config, optional: true
    has_many :wechat_notices, dependent: :delete_all

    before_create :sync_to_wechat
    after_destroy_commit :del_to_wechat
  end

  def init_template_config
    if wechat_app.is_a?(WechatPublic)
      config = TemplatePublic.find_or_initialize_by(content: content)
      config.title = title
      self.template_config = config
      self.save
    end
  end

  def sync_to_wechat
    return if template_id.present?
    r = wechat_app.api.add_template(template_config.tid, template_config.kid_list)
    logger.debug(r['errmsg'])
    if r['errcode'] == 0
      self.template_id = r['priTmplId']
    else
      return
    end
    r_content = wechat_app.api.templates.find { |i| i['priTmplId'] == self.template_id }
    self.template_type = r_content['type']
    self.assign_attributes r_content.slice('title', 'content', 'example')
    self
  end

  def sync_to_wechat!
    sync_to_wechat
    save
  end

  def del_to_wechat
    r = wechat_app.api.del_template(template_id)
    logger.debug(r['errmsg'])
  end

  def messenger
    wechat_app.template_messenger(self)
  end

  def data_keys
    content.gsub(/(?<={{)\w+(?=.DATA}})/).to_a
  end

  def data_mappings
    if template_config
      template_config.data_hash
    else
      {}
    end
  end

end
