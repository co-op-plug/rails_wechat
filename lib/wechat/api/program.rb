# frozen_string_literal: true

class Wechat::Api::Program < Wechat::Api::Base
  WXAAPI = 'https://api.weixin.qq.com/wxaapi/'
  # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/sec-check/security.msgSecCheck.html
  def msg_sec_check(content)
    post 'msg_sec_check', { content: content }, base: WXA_BASE
  end

  # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/template-message/templateMessage.getTemplateList.html
  def templates
    r = get 'newtmpl/gettemplate', base: WXAAPI
    if r['errcode'] === 0
      r['data']
    else
      Rails.logger.info r
      []
    end
  end

  # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.getPubTemplateKeyWordsById.html
  def template_key_words(tid)
    r = get 'newtmpl/getpubtemplatekeywords', params: { tid: tid }, base: WXAAPI
    r['data']
  end

  def add_template(tid, kid_list, description: 'tst')
    post 'newtmpl/addtemplate', { tid: tid, kidList: kid_list, sceneDesc: description }, base: WXAAPI
  end

  def del_template(template_id)
    post 'newtmpl/deltemplate', {}, params: { priTmplId: template_id }, base: WXAAPI
  end

  def get_wxacode(path, width = 430)
    post 'getwxacode', { path: path, width: width }, base: WXA_BASE
  end

  def get_wxacode_unlimit(scene, **options)
    p = { scene: scene, **options }
    post 'getwxacodeunlimit', p, base: WXA_BASE
  end

  # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/login/auth.code2Session.html
  def jscode2session(code)
    params = {
      appid: app.appid,
      secret: app.secret,
      js_code: code,
      grant_type: 'authorization_code'
    }

    get 'jscode2session', params: params, base: SNS_BASE
  end

end
