Rack ||= Module.new
Rack::APP ||= Class.new
Rack::APP::VERSION = File.read(File.join(File.dirname(__FILE__), '..', '..', '..', 'VERSION')).strip