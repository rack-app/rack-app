require "spec_helper"
describe 'rack-app inheritance for mounted file servers' do

  include Rack::App::Test

  rack_app do

    klass = Class.new(Rack::App)
    klass.class_eval do
      serve_files_from '/spec/fixtures'
    end

    mount klass, :to => '/spec/fixtures'

  end

  it { expect(get('/spec/fixtures/hello/world').body).to eq "Hello, World!" }

end
