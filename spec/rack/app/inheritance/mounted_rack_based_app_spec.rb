require "spec_helper"
describe 'rack-app inheritance for mounted rack interface compatible application' do

  include Rack::App::Test

  rack_app do

    rack_based_application = Class.new(Rack::App)
    rack_based_application.class_eval do

      get '/hello/world' do
        "Hello, World!"
      end

    end

    klass = Class.new(Rack::App)
    klass.class_eval do
      mount_rack_based_application rack_based_application
    end

    mount klass, :to => '/mount/point'

  end

  it { expect(get('/mount/point/hello/world').body).to eq "Hello, World!" }

end
