# coding: utf-8
Gem::Specification.new do |spec|

  spec.name = 'rack-app'
  spec.version = File.read(File.join(File.dirname(__FILE__), 'VERSION')).strip
  spec.authors = ['Adam Luzsi']
  spec.email = ['adamluzsi@gmail.com']

  summary = 'Minimalist rack application interface building framework.'
  spec.summary = summary
  spec.description = summary
  spec.homepage = 'http://www.rack-app.com/'
  spec.license = 'Apache License 2.0'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_dependency 'rack', '<= 3.0.0'
  spec.add_dependency 'rackup'

end