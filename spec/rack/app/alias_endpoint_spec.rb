require 'spec_helper'

describe Rack::App do

  require 'rack/app/test'
  include Rack::App::Test

  rack_app do

    get '/a' do
      'this is "A"'
    end

    alias_endpoint '/b', '/a'

  end

  describe '.alias_endpoint' do

    it{ expect(get(:url => '/b').body).to eq 'this is "A"' }

  end

  describe '.root' do
    context 'given there is already an endpoint' do

      rack_app do

        options '/hello' do
          response.status = 777
        end

        get '/hello' do
          'WORLD'
        end

        root '/hello'

      end

      it "should define GET endpoint that point to the given request path's endpoint" do
        expect(get(:url => '/').body).to eq 'WORLD'
      end

      it 'should define GET endpoint that point to the given request path\'s endpoint' do
        expect(options(:url => '/').status).to eq 777
      end

      it 'should not define request_method that is not pointing to an existing one' do
        expect(patch(:url => '/').status).to eq 404
      end

    end
  end

end