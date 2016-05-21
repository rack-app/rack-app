require 'spec_helper'

describe Rack::App do

  require 'rack/app/test'
  include Rack::App::Test

  rack_app do

    get '/redirect' do
      redirect_to '/hello'
    end

    get '/redirect_with_additional_header' do
      response.headers['X-AUTH']= 'yes please'

      redirect_to '/hello'
    end

  end

  describe '#redirect_to' do

    it{ expect(get(:url => '/redirect').status).to eq 301 }

    context 'when no query string was given' do
      it{ expect(get(:url => '/redirect').headers).to include({'Location' => '/hello'}) }
    end

    context 'additional headers setted in the endpoint before redirection' do
      it{ expect(get(:url => '/redirect_with_additional_header').headers).to include({'Location' => '/hello','X-AUTH' => 'yes please'}) }
    end

    context 'when query string was given' do
      it{ expect(get(:url => '/redirect', :params => {'hello'=>'world'}).headers).to include({'Location' => '/hello?hello=world'}) }
    end

  end

end