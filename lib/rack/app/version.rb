Rack ||= Module.new
Rack::App ||= Class.new
Rack::App::VERSION = File.read(File.join(File.dirname(__FILE__), '..', '..', '..', 'VERSION')).strip