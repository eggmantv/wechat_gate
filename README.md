# WechatGate

**微信公众平台开发库**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wechat-gate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wechat-gate

## Settings

在开工之前你需要在微信公众账号平台做以下配置:

1. 开通你的公众号（服务号），并开通微信认证（300元认证服务费）
2. 在公众号后台“公众号设置” － “功能设置”中设置你的JS接口安全域名，就是你的公众号调用的网站的域名
3. 在“接口权限” － “网页授权获取用户基本信息”中设置你的授权回调页面域名，这个用于OAuth2的回调域名认证
4. 在“基本配置”中查看并配置你的AppID和AppSecret

## Usage

1.在Rails项目config目录下建立文件wechat.yml，并配置你的公众号信息.

```
  app_name:
    app_id: idstring
    app_secret: secret
    oauth2_redirect_uri: "http://www.example.com/api/wechat_oauth/callback"
```

2.在Controller中调用(用于微信JS-SDK)

```ruby
  def ticket
    url = CGI.unescape(params[:url]) # 微信中用户访问的页面
    config = WechatGate::Config.new('app_name')
    @data = config.generate_js_request_params(url) # 生成微信JS-SDK所需的jsapi_ticket，signature等等参数供前段js使用
    render content_type: "application/javascript"
  end
```

ticket.js.erb:

```
var wxServerConfig = <%= @data.to_json.html_safe %>;
<%= params[:callback] %>();
```

然后在微信端页面引入一下代码:

```js
(function() {
  var ticket = document.createElement("script");
  ticket.src = "http://localhost/api/wechat_ticket/ticket.js?url=" + encodeURIComponent(window.location.href.split('#')[0]) + "&callback=wxCallback";
  var s = document.getElementsByTagName("script")[0];
  s.parentNode.insertBefore(ticket, s);
})();
```


**如果不是利用JS-SDK，而是后台API操作(比如微信用户信息获取等等操作)，可以直接利用以下方法来获取access_token:**
```ruby
config = WechatGate::Config.new('app_name')
config.refresh_access_token
config.refresh_jsapi_ticket
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/wechat. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
