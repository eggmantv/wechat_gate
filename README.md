# WechatGate

**微信公众平台开发库**

支持的接口:

- access_token(后端API使用)
- 用户授权信息获取(OAuth2)
- JS-SDK
- 回复消息封装
- 菜单接口
- 素材接口

功能特点:

- 自动管理access_token和JS-SDK的ticket刷新和过期
- 多微信公众号支持
- 多环境支持(development, production)，方便本地测试
- Controler和helper方法(微信session管理等等)
- 接口简单，方便定制

使用视频教程: [微信公众号开发](https://eggman.tv/c/s-wechat-development-using-ruby-on-rails)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wechat-gate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wechat-gate

## 公众号

在开工之前你需要在微信公众账号平台做以下配置:

1. 开通你的公众号（服务号），并开通微信认证（300元认证服务费）
2. 在公众号后台“公众号设置” － “功能设置”中设置你的JS接口安全域名，就是你的公众号调用的网站的域名
3. 在“接口权限” － “网页授权获取用户基本信息”中设置你的授权回调页面域名，这个用于OAuth2的回调域名认证
4. 在“基本配置”中查看并配置你的AppID和AppSecret

## 配置

在Rails项目config目录下建立文件wechat.yml，并配置你的公众号信息.

```
# 区分不同的环境
eggman:
  development:
    host: http://wechat-test1.eggman.tv

    wechat_id: xxxxxxxxxx
    app_id: xxxxxxxxxx
    app_secret: xxxxxxxxxx

    oauth2_redirect_uri: "http://wechat-test1.eggman.tv/wechat/users/callback"

    push_url: "http://wechat-test1.eggman.tv/wechat/push"
    push_token: xxxxxxxxxxxxxxxxxxxx
  production:
    host: https://eggman.tv

    wechat_id: xxxxxxxxxx
    app_id: xxxxxxxxxxxxxxxxxxxx
    app_secret: xxxxxxxxxxxxxxxxxxxxxxxxxx

# 如果不需要多环境支持，也可以这样
app_name:
  app_id: <%= ENV['WECHAT_APP_NAME_APP_ID'] %>
  app_secret: <%= ENV['WECHAT_APP_NAME_APP_SECRET'] %>
  oauth2_redirect_uri: <%= ENV['WECHAT_APP_NAME_OAUTH2_REDIRECT_URI'] %>
```

然后在ApplicationController中指定当前要读取的公众号名称：

```
self.wechat_gate_app_name = 'eggman'
```

## 后端调用

后台API操作(比如微信用户信息获取等等操作)。

默认情况下在controller中已经初始化了配置，方法为**wechat_gate_config**，直接使用就行。


```ruby
wechat_gate_config.users # 获取用户列表
wechat_gate_config.user('ONE_OPEN_ID') # 获取一个用户的详细信息
wechat_gate_config.access_token # 获取当前access_token

# OAuth 2
wechat_gate_config.oauth2_entrance_url(scope: "snsapi_userinfo", state: "CURENT_STATE") # 获取当前OAuth2授权入口URL
wechat_gate_config.oauth2_access_token("TOKEN") # 根据OAuth2返回的TOKEN获取access_token
wechat_gate_config.oauth2_user("ACCESS_TOKEN", "ONE_OPEN_ID") # 获取一个用户的信息

wechat_gate_config.medias # 获取素材列表, 参数type: image | video | voice | news (图文)

wechat_gate_config.menu_get # 获取菜单
wechat_gate_config.menu_create(MENU_HASH) # 创建菜单

wechat_gate_config.generate_js_request_params(REFERER_URL) # 返回JS-SDK的验证参数，供前端JS-SDK使用
```

当然你也可以手工来初始化配置，甚至指定配置文件的路径：

```
config = WechatGate::Config.new('eggman', '/path/to/what/ever/you/want.yml')
```

access_token和JS_SDK中ticket都有过期时间和刷新次数限制，这里已经考虑了，你可以不用管，如果你想手工刷新，可以这样:

```
config.refresh_access_token
config.refresh_jsapi_ticket
```

**配置文件支持erb**

> 更多接口和文档请直接看源码，写的很详细

## JS-SDK

```ruby
  def ticket
    url = CGI.unescape(params[:url]) # 微信中用户访问的页面
    @data = wechat_gate_config.generate_js_request_params(url) # 生成微信JS-SDK所需的jsapi_ticket，signature等等参数供前段js使用
    render content_type: "application/javascript"
  end
```

ticket.js.erb:

```
var wxServerConfig = <%= @data.to_json.html_safe %>;
<%= params[:callback] %>();
```

然后在微信端页面引入以下代码:

```js
(function() {
  var ticket = document.createElement("script");
  ticket.src = "http://localhost/api/wechat_ticket/ticket.js?url=" + encodeURIComponent(window.location.href.split('#')[0]) + "&callback=wxCallback";
  var s = document.getElementsByTagName("script")[0];
  s.parentNode.insertBefore(ticket, s);
})();
```

## 其他功能

### 自定义菜单

首先设置菜单配置文件，config/wechat_menu.yml，支持erb，格式请参考[微信自定义菜单文档](https://mp.weixin.qq.com/wiki):

```
button:
  - type: view
    name: 我的2
    url: <%= @config.oauth2_entrance_url(scope: 'snsapi_userinfo', state: 'profile') %>
  - type: view
    name: 课程
    sub_button:
      - type: view
        name: 免费课程
        url:  <%= @config.oauth2_entrance_url(scope: 'snsapi_userinfo', state: 'free') %>
      - type: view
        name: 付费课程
        url:  <%= @config.oauth2_entrance_url(scope: 'snsapi_userinfo', state: 'paid') %>
```

> 其中的**@config**变量为当前微信公众号实例，请不要修改，直接使用

然后执行rake任务:

```shell
$rails wechat_gate:create_menu APP_NAME=eggman CONFIG=/path/to/wechat.yml MENU=/path/to/wechat_menu
```

其中，CONFIG默认为config/wechat.yml，MENU默认为config/wechat_menu.yml，APP_NAME必须指定

## TODO

添加测试
