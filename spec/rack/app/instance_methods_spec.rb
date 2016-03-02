require 'spec_helper'
require 'rack/app/test'

InstanceMethodsSpec = Class.new
describe Rack::App::InstanceMethods do

  include Rack::App::Test

  rack_app do

    get '/serve_file' do
      serve_file Rack::App::Utils.pwd('spec', 'fixtures', 'raw.txt')
    end

    get '/redirect_to' do
      redirect_to '/hello'
    end

  end

  describe '#serve_file' do

    it 'should serve file content with Rack::File' do
      response = get(:url => '/serve_file')

      expect(response.body).to be_a ::Rack::File

      content = ''
      response.body.each { |chunk| content << chunk }

      expect(content).to eq "hello world!\nhow you doing?"

    end

  end

  describe '#redirect_to' do

    it 'should set status to 301' do
      expect(get(:url => '/redirect_to').status).to eq 301
    end

    it 'should add location header' do
      expect(get(:url => '/redirect_to').headers['Location']).to eq '/hello'
    end

    it 'should add params to location url too to proxy the request' do
      expect(get(:url => '/redirect_to', :params => {'hello' => 'world'}).headers['Location']).to eq '/hello?hello=world'
    end

  end

end