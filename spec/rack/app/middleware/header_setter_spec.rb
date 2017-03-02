require 'spec_helper'
describe Rack::App do

  include Rack::App::Test

  describe '.headers' do

    rack_app do

      headers 'Access-Control-Allow-Origin' => '*',
              'Access-Control-Expose-Headers' => 'X-My-Custom-Header, X-Another-Custom-Header',
              ::Rack::CONTENT_TYPE => 'application/json'

      get '/' do
        '{}'
      end

      get '/acao' do
        response.headers['Access-Control-Allow-Origin']= 'not default'
      end

    end

    it { expect(get(:url => '/').headers[::Rack::CONTENT_TYPE]).to eq 'application/json' }

    it { expect(get(:url => '/').headers['Access-Control-Allow-Origin']).to eq '*' }

    it { expect(get(:url => '/acao').headers['Access-Control-Allow-Origin']).to eq 'not default' }

    it { expect(get(:url => '/').headers['Access-Control-Expose-Headers']).to eq 'X-My-Custom-Header, X-Another-Custom-Header' }

  end

end
