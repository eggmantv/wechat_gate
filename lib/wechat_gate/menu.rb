require 'wechat_gate/request'

module WechatGate
  module Menu
    def menu_get
      WechatGate::Request.send(
        "https://api.weixin.qq.com/cgi-bin/menu/get?access_token=#{self.access_token}"
      )
    end

    def menu_create(menu_hash)
      WechatGate::Request.send(
        "https://api.weixin.qq.com/cgi-bin/menu/create?access_token=#{self.access_token}",
        :post,
        menu_hash
      )
    end
  end


end
