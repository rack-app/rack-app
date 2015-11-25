require 'spec_helper'
describe Rack::App::Runner do

  let(:request_method) { 'GET' }
  let(:request_path) { '/hello' }

  let(:request_env) do
    {
        'REQUEST_METHOD' => request_method,
        'REQUEST_PATH' => request_path
    }
  end

  let(:api_class) do
    klass = Class.new(Rack::App)
    klass.class_eval do

      get '/hello' do
        status 201

        'valid_endpoint'
      end

    end

    klass
  end

  describe '#response_for' do
    subject { described_class.response_for(api_class, request_env) }
    let(:response_body) { subject[2].body[0] }
    let(:response_status) { subject[2].status }

    context 'when there is a valid endpoint for the request' do
      it { expect(response_body).to eq 'valid_endpoint' }

      it { expect(response_status).to eq 201 }
    end

    context 'when there is no endpoint registered for the given request' do
      before{ request_env['REQUEST_PATH']= '/unknown/endpoint/path' }

      it { expect(response_body).to eq '404 Not Found' }

      it { expect(response_status).to eq 404 }
    end

  end

end