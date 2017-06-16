require 'spec_helper'

RSpec.describe Rack::App do
  include Rack::App::Test

  app1 = Class.new(Rack::App)
  app1.class_eval do
    use SimpleSetterMiddleware, 'override', 'run last'

    get '/testing' do
      request.env['override']
    end

    next_endpoint_middlewares do |builder|
      builder.use SimpleSetterMiddleware, 'override', 'run final'
    end
    get '/final' do
      request.env['override']
    end
  end

  app2 = Class.new(Rack::App)
  app2.class_eval do
    use SimpleSetterMiddleware, 'override', 'run first'

    mount app1
  end

  rack_app do
    use SimpleSetterMiddleware, 'test', 'value'

    mount ExampleRackApp
    mount app2
  end

  describe 'mounted app should be using the app middlewares too' do
    it { expect(get('/fetch/test').body).to eq 'value' }
    it { expect(get('/testing').body).to eq 'run last' }
    it { expect(get('/final').body).to eq 'run final' }
  end
end
