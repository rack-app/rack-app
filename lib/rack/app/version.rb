require 'rack/app'
Rack::App::VERSION = File.read(File.join(File.dirname(__FILE__), '..', '..', '..', 'VERSION')).strip