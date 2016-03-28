# coding: utf-8
Gem::Specification.new do |spec|

  spec.name          = "rack-app"
  spec.version       = File.read(File.join(File.dirname(__FILE__), 'VERSION')).strip
  spec.authors       = ["Adam Luzsi"]
  spec.email         = ["adamluzsi@gmail.com"]

  spec.summary       = %q{Your next favourite, performance designed micro framework!}
  spec.description   = %q{Your next favourite rack based micro framework that is totally addition free! Have a cup of awesomeness with your to performance designed framework!}

  spec.homepage      = 'http://www.rack-app.com/'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.license       = 'Apache License 2.0'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", '10.4.2'
  spec.add_development_dependency "rspec"

  spec.add_dependency "rack"

end