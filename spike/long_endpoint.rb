rack_api_lib_folder = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift(rack_api_lib_folder)

require "rack/app"
require "rack/mock"
require "benchmark"

class App < Rack::App

  get "/a/b/c/:d/e/f/:g/h/i/j/k/l/m/n/o/p/q/:something" do
    return 'Hello, World!'
  end

end


request = Rack::MockRequest.new(App)

Benchmark.bm do |x|
  x.report do
    request.get("/a/b/c/dog/e/f/goat/h/i/j/k/l/m/n/o/p/q/chicken" )
  end
end

result = Benchmark.measure do

end

puts result
