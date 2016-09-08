require "spec_helper"
describe "Simple example" do

  include Rack::App::Test

  rack_app do

    desc 'Hello, World!'
    get '/hello' do
      'Hello, World!'
    end

  end

  it { expect(get('/hello').body).to eq "Hello, World!" }

end
