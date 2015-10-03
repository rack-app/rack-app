# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/app/version'

Gem::Specification.new do |spec|

  spec.name          = "rack-app"
  spec.version       = Rack::APP::VERSION
  spec.authors       = ["Adam Luzsi"]
  spec.email         = ["adamluzsi@gmail.com"]

  spec.summary       = %q{Bare bone minimalistic (masochistic) pico framework for building rack apps}
  spec.description   = %q{Bare bone minimalistic (masochistic) pico framework for building rack apps}
  spec.homepage      = "https://github.com/adamluzsi/rack-app.rb"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_dependency "rack"

end
