require 'spec_helper'
describe Rack::App do

  require 'rack/app/test'
  include Rack::App::Test

  describe '.next_endpoint_middlewares' do

    rack_app do

      next_endpoint_middlewares do |builder|
        builder.use SampleMiddleware, 'key', 'OK'
      end

      get '/affected' do
        request.env['key']
      end

      get '/unaffected' do
        request.env['key']
      end

    end

    let(:request){ get(:url => path) }

    context 'when endpoint is affected by the middleware stack' do
      let(:path){ '/affected' }

      it{ expect(request.body).to eq 'OK' }
    end

    context 'when endpoint is unaffected by the middleware stack' do
      let(:path){ '/unaffected' }

      it{ expect(request.body).to eq '' }
    end

  end

end
