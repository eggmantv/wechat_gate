require 'wechat_gate/request'

module WechatGate
  module User
    def users(next_openid = nil)
      WechatGate::Request.send("https://api.weixin.qq.com/cgi-bin/user/get?access_token=#{self.access_token}&next_openid=#{next_openid}")
    end

    def user(openid)
      WechatGate::Request.send("https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{self.access_token}&openid=#{openid}&lang=zh_CN")
    end

  end


end
