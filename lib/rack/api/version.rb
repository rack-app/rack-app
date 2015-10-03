Rack ||= Module.new
Rack::API ||= Class.new
Rack::API::VERSION = File.read(File.join(File.dirname(__FILE__), '..', '..', '..', 'VERSION')).strip