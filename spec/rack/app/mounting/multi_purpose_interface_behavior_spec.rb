require "spec_helper"
describe 'rack-app #mount method can mount rack-app object and rack interface compatible application too' do

  include Rack::App::Test

  rack_app do

    rack_based_application = lambda { |env| [200, {"Content-Type" => "text/html"}, ["Hello, World!"]] }

    klass = Class.new(Rack::App)
    klass.class_eval do
      get '/test' do
        'OK'
      end
    end

    mount klass, :to => '/rack-app'
    mount rack_based_application, :to => '/rack-interface-compatible-app'

  end

  it { expect(get('/rack-interface-compatible-app/test').body).to eq "Hello, World!" }
  # it { expect(get('/rack-interface-compatible-app').body).to eq "Hello, World!" }
  it { expect(get('/rack-app/test').body).to eq "OK" }

end
