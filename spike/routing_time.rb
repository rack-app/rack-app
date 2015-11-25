$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rack/app'
require 'securerandom'

static_router =  Rack::App::Router::Static.new
dynamic_router = Rack::App::Router::Dynamic.new

classic_router = []

endpoint_paths = []
10000.times do
  endpoint_paths << ('/' + 7.times.map { SecureRandom.uuid }.join('/'))

  static_router.add_endpoint('GET', endpoint_paths.last, -> {})
  static_router.add_endpoint('GET', endpoint_paths.last, -> {})
  classic_router << ['GET',endpoint_paths.last,->{}]

end

start_time = Time.now
endpoint_paths.each do |request_path|
  static_router.fetch_endpoint('GET',request_path)
end
finish_time_of_static = Time.now - start_time

start_time = Time.now
endpoint_paths.each do |request_path|
  dynamic_router.fetch_endpoint('GET',request_path)
end
finish_time_of_dynamic = Time.now - start_time

start_time = Time.now
endpoint_paths.each do |request_path|
  classic_router.find{|ary| ary[0] == 'GET' and ary[1] == request_path }
end
finish_time_of_classic = Time.now - start_time

puts "time taken by static: #{finish_time_of_static}",
     "time taken by dynamic: #{finish_time_of_dynamic}",
     "time taken by classic(mock): #{finish_time_of_classic}"
