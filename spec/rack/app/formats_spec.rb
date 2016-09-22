require "spec_helper"
describe "Rack::App#formats" do

  include Rack::App::Test

  describe 'should serve request for the requested format format' do

    rack_app do

      get '/test' do
        {"type" => "static"}
      end

      get '/test/:id/ep' do
        {"type" => "dynamic with static last url part", 'id' => params['id']}
      end

      get '/test/:id' do
        {"type" => "dynamic endpoint endpoint", 'id' => params['id']}
      end

      formats do
        on '.yaml', 'application/x-yaml' do |obj|
          YAML.dump(obj)
        end
      end

    end

    it 'should work with static endpoints' do
      get("/test.yaml")

      expect(last_response.body).to eq YAML.dump({"type" => "static"})
      expect(last_response.headers).to include 'Content-Type' => 'application/x-yaml'
    end

    context 'should work with static endpoints' do

      it 'should end with a normal url part' do
        get("/test/123/ep.yaml")

        expect(last_response.body).to eq YAML.dump({"type" => "dynamic with static last url part", "id" => "123"})

        expect(last_response.headers).to include 'Content-Type' => 'application/x-yaml'
      end

      it 'should end with a dynamic url part' do
        get("/test/123.yaml")

        expect(last_response.body).to eq YAML.dump({"type" => "dynamic endpoint endpoint", "id" => "123"})
        expect(last_response.headers).to include 'Content-Type' => 'application/x-yaml'
      end

    end

  end

  context 'when not defined format used' do
    rack_app do

      formats do
        on '.yaml', 'application/x-yaml' do |obj|
          YAML.dump(obj)
        end

        default 'text/plain or what ever' do |obj|
          obj.to_s.upcase
        end

      end

      get '/test' do
        'Hello'
      end

    end

    it 'should use the default format than' do
      get '/test'
      expect(last_response.body).to eq 'HELLO'
      expect(last_response.headers).to include 'Content-Type' => 'text/plain or what ever'
    end

  end

  context 'when no format given for request serializer block ackt as a default block in formats' do
    rack_app do

      formats do
        on '.yaml', 'application/x-yaml' do |obj|
          YAML.dump(obj)
        end
      end

      serializer 'text/plain or what ever' do |obj|
        obj.to_s.upcase
      end

      get '/test' do
        'Hello'
      end

    end

    it 'should use the default format than' do
      get '/test'
      expect(last_response.body).to eq 'HELLO'
      expect(last_response.headers).to include 'Content-Type' => 'text/plain or what ever'
    end

  end

end
