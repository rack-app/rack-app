require 'spec_helper'
describe Rack::App::Router::Dynamic do

  include Rack::App::Test

  rack_app do

    get '/hello' do
      'world'
    end

    get '/users/:user_id' do
      YAML.dump(params)
    end

    get '/users/:user_id/documents/:document_id' do
      YAML.dump(params)
    end

  end

  describe '#call' do

    it 'should return the the path parameter' do
      expect(YAML.load(get('/users/1').body)).to eq({'user_id' => '1'})
    end

    it 'should return the the path parameter even on multiple partially matching endpoints' do
      expect(YAML.load(get('/users/1/documents/2').body)).to eq({'user_id' => '1', 'document_id' => '2'})
    end

    context 'when file handler registered' do

      rack_app do

        serve_files_from '/spec/fixtures'

      end

      it 'should return mounted directory handler' do
        expect(YAML.load(get('/hello/world').body)).to eq('Hello, World!')
      end

      it 'should return mounted directory handler even with partially matching path' do
        expect(YAML.load(get('/hello/test/awesome.js').body)).to eq("console.log('hello world');")
      end

      it 'should return nothing so the 404 handler can be returned' do
        path_info = '/hello/world/not_found'
        expect(get(path_info).body).to match(/^File not found/)
        expect(get(path_info).status).to eq(404)
      end

    end

    it 'should return nothing so the 404 handler can be returned' do
      expect(get('/users/1/documents/2/dog').body).to eq("404 Not Found")
      expect(get('/users/1/documents/2/dog').status).to eq(404)
    end

  end

end