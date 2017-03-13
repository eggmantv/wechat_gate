# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wechat_gate/version'

Gem::Specification.new do |spec|
  spec.name          = "wechat-gate"
  spec.version       = WechatGate::VERSION
  spec.authors       = ["Lei Lee"]
  spec.email         = ["mytake6@gmail.com"]

  spec.summary       = %q{另一个微信开发的Ruby Gem}
  spec.description   = %q{接口简单易用，实在是微信开发必备之好Gem}
  spec.homepage      = "https://github.com/eggmantv/wechat_gate"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client", '~> 1.8'
  spec.add_dependency "activesupport", '~> 5.0.1'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"

end
