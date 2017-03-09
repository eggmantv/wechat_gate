require 'active_support/core_ext/module/attribute_accessors'
require 'wechat_gate/request'

module WechatGate
  module SendMessage

    #
    # https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140549&token=&lang=zh_CN
    # 这个接口有发送限制，服务号每月只能发送4次，订阅号每天一次
    #
    def mass_send open_ids, msg_options = {}
      payload = {
         "touser": [open_ids].flatten,
          "msgtype": "text",
          "text": { "content": "hello from boxer."}
      }.merge(msg_options)

      WechatGate::Request.send(
        "https://api.weixin.qq.com/cgi-bin/message/mass/send?access_token=#{self.access_token}",
        :post,
        payload.to_json
      )
    end

    #
    # 这个是微信的私有接口，在微信网页端才能使用，给单个用户发消息，而且没有发送数量限制，
    # 这里是模拟公众号登录，然后给用户发送消息（在“用户管理”页面点击单个用户）
    #
    # **这个接口要求48小时内只能发送20条**
    # **用户在48小时内与公众账号只要发生互动（点击公众号菜单或者发过消息），阀值就会刷新**
    #
    # Request URL:https://mp.weixin.qq.com/cgi-bin/singlesend?t=ajax-response&f=json&token=1927434739&lang=zh_CN
    # Request Method:POST
    # Query String:
    #   t:ajax-response
    #   f:json
    #   token:1927434739
    #   lang:zh_CN
    # Form Data
    #   token:1927434739
    #   lang:zh_CN
    #   f:json
    #   ajax:1
    #   random:0.9569772763087352
    #   type:1
    #   content:ll
    #   tofakeid:oMZZkwziWkGiXq3-RjGHcgXn6v70
    #   imgcode:
    #
    mattr_accessor :single_send_cookies
    mattr_accessor :single_send_token
    mattr_accessor :single_send_cookies_refreshed_at
    mattr_accessor :single_send_cookies_expired_in

    mattr_accessor :single_send_ua

    #
    # 在公众号端没有cookie过期的概念，这里把登录后的cookie和token缓存起来，为了不频繁的登录公众号
    #
    # **这个功能只能在生产环境的真实公众账号中测试，不支持在沙盒中测试**
    #
    self.single_send_cookies_refreshed_at = Time.now.to_i
    self.single_send_cookies_expired_in = 3600

    self.single_send_ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.110 Safari/537.36"

    def single_send open_id, content
      single_send_if_need_refresh_cookie

      opts = {
        method: :post,
        url: "https://mp.weixin.qq.com/cgi-bin/singlesend?t=ajax-response&f=json&token=#{self.single_send_token}&lang=zh_CN",
        verify_ssl: false,
        payload: {
          token: self.single_send_token,
          lang: "zh_CN",
          f: "json",
          ajax: 1,
          random: Random.rand,
          type: 1, # 文本消息
          content: content,
          tofakeid: open_id,
          imgcode: ""
        }.to_query,
        headers: {
          'User-Agent': self.single_send_ua,
          'Cookie': self.single_send_cookies,
          'Referer': "https://mp.weixin.qq.com/cgi-bin/singlesendpage?t=message/send&action=index&tofakeid=#{open_id}&token=#{self.single_send_token}&lang=zh_CN"
        }
      }

      response = RestClient::Request.execute(opts)
      data = JSON.parse(response)
      raise response.to_s if data['errmsg'] and data['errmsg'] != 'ok'
      data
    end

    private
    def single_send_if_need_refresh_cookie
      if self.single_send_cookies.nil? ||
        (Time.now.to_i - self.single_send_cookies_refreshed_at > self.single_send_cookies_expired_in)
        single_send_login_and_refresh_cookies_w_token
      end
    end

    #
    # 登录公众号，缓存登录后的cookie和token
    #
    def single_send_login_and_refresh_cookies_w_token
      opts = {
        method: :post,
        url: "https://mp.weixin.qq.com/cgi-bin/login?lang=zh_CN",
        verify_ssl: false,
        payload: {
          username: self.specs['wechat_login_username'],
          pwd: Digest::MD5.hexdigest(self.specs['wechat_login_password']),
          imgcode: "",
          f: "json"
        }.to_query,
        headers: {
          'User-Agent': self.single_send_ua,
          'Referer': 'https://mp.weixin.qq.com/'
        }
      }

      response = RestClient::Request.execute(opts)
      data = JSON.parse(response)
      raise response.to_s if data['errmsg'] and data['errmsg'] != 'ok'

      self.single_send_cookies = response.cookies.map {|k, v| k + "=" + v}.join("; ")
      data["redirect_url"].gsub(/token=(\d+)/) { |x| self.single_send_token = $1 }
      self.single_send_cookies_refreshed_at = Time.now.to_i
    end

  end


end
