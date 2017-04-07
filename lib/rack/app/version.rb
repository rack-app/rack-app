require 'rack/app' unless defined?(Rack::App)
Rack::App::VERSION = File.read(File.join(File.dirname(__FILE__), '..', '..', '..', 'VERSION')).strip