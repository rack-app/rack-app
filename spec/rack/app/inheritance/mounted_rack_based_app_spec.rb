require "spec_helper"
describe 'rack-app inheritance for mounted rack interface compatible application' do

  include Rack::App::Test

  rack_app do

    rack_based_application = lambda { |env| [200, {"Content-Type" => "text/html"}, ["Hello, World!"]] }

    klass = Class.new(Rack::App)
    klass.class_eval do
      mount_rack_interface_compatible_application rack_based_application
    end

    mount klass, :to => '/mount/point'

  end

  it { expect(get('/mount/point/hello/world').body).to eq "Hello, World!" }

end
