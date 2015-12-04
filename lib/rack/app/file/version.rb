module Rack
end unless defined?(Rack)
class Rack::App
end unless defined?(Rack::App)
module Rack::App::File
  VERSION = File.read(File.join(File.dirname(__FILE__),'..','..', '..', '..', 'VERSION')).strip
end