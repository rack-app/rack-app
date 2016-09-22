require "spec_helper"
describe Rack::App do

  include Rack::App::Test

  rack_app do

    formats do
      on '.yaml', 'application/x-yaml' do |obj|
        YAML.dump(obj)
      end
    end

    serializer do |obj|
      obj.inspect
    end

    get '/test' do
      {"type" => "static"}
    end

    get '/test/:id/ep' do
      {"type" => "dynamic with static last url part", 'id' => params['id']}
    end

    get '/test/:id' do
      {"type" => "dynamic endpoint endpoint", 'id' => params['id']}
    end

  end

  describe 'should serve request for the requested format format' do

    it 'should work with static endpoints' do
      expect(get("/test.yaml").body).to eq YAML.dump({"type" => "static"})
    end

    context 'should work with static endpoints' do

      it 'should end with a normal url part' do
        expect(get("/test/123/ep.yaml").body).to eq YAML.dump({"type" => "dynamic with static last url part", "id" => "123"})
      end

      it 'should end with a dynamic url part' do
        expect(get("/test/123.yaml").body).to eq YAML.dump({"type" => "dynamic endpoint endpoint", "id" => "123"})
      end

    end

  end

end
