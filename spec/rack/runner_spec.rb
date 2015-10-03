require 'spec_helper'
describe Rack::API::Runner do

  let(:request_env) { {} }
  let!(:request) { Rack::Request.new(request_env) }
  let!(:response) { Rack::Response.new }

  let(:api_class) do
    klass = Class.new(Rack::API)
    klass.class_eval do

      get '/hello' do
        'world'
      end

    end
    klass
  end

  describe '#response_for' do
    it 'should create api_class with the right request and response object' do
      expect(api_class).to receive(:new).with(request, response)

    end

    context 'when endpoint is not defined' do


    end


  end

end