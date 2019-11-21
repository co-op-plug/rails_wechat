# frozen_string_literal: true

module Wechat::Api
  class Program < Common
    
    # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/sec-check/security.msgSecCheck.html
    def msg_sec_check(content)
      post 'msg_sec_check', { content: content }, base: WXA_BASE
    end
    
    def template_message_send(message)
      post 'message/wxopen/template/send', message, headers: { content_type: :json }
    end

    def list_template_library(offset: 0, count: 20)
      post 'wxopen/template/library/list', { offset: offset, count: count }, base: WXA_BASE
    end

    def list_template_library_keywords(id)
      post 'wxopen/template/library/get', id: id
    end

    def add_message_template(id, keyword_id_list)
      post 'wxopen/template/add', id: id, keyword_id_list: keyword_id_list
    end

    def list_message_template(offset: 0, count: 20)
      post 'wxopen/template/list', offset: offset, count: count
    end

    def del_message_template(template_id)
      post 'wxopen/template/del', template_id: template_id
    end

    def jscode2session(code)
      params = {
        appid: app.appid,
        secret: app.secret,
        js_code: code,
        grant_type: 'authorization_code'
      }

      client.get 'jscode2session', params: params, base: OAUTH2_BASE
    end
    
  end
end
