require "spec_helper"
describe Rack::App do
  include Rack::App::Test

  context 'before hook should be applied after the next_endpoint_middlewares' do
    rack_app do

      before do
        unless request.env['no_validation_please']
          http_status!(418) # unpassable teapot auth
        end
      end

      next_endpoint_middlewares do |b|
        b.use SimpleSetterMiddleware, 'no_validation_please', true
      end
      get '/public' do
      end

      get '/private' do
      end

    end

    it { expect(get('/public').status).to eq 200 }
    it { expect(get('/private').status).to eq 418 }

  end

end
