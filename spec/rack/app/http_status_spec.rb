require "spec_helper"
describe Rack::App do
  include Rack::App::Test

  describe '#http_status!' do

    rack_app do

      Rack::App::Constants::HTTP_STATUS_CODES.each do |code, _|
        get "/#{code}" do
          http_status!(code)

          raise
        end
      end

      get '/custom_desc' do
        http_status!(418, "I'm a teapot! :)")
      end
    end

    Rack::App::Constants::HTTP_STATUS_CODES.each do |code, desc|
      context "when #{code} status code given" do

        it "should responds with: #{desc}" do
          get("/#{code}")

          expect(last_response.status).to eq code

          unless Rack::Utils::STATUS_WITH_NO_ENTITY_BODY.include?(code)
            expect(last_response.body).to eq desc
          end
        end

      end

    end

    context 'when custom description given' do
      it 'should use instead of the standard' do
        get("/custom_desc")
        expect(last_response.status).to eq 418
        expect(last_response.body).to eq "I'm a teapot! :)"
      end
    end

    context 'when serialization is defined' do
      content = { "hello" => "world" }
      require 'json'
      rack_app do

        serializer do |object|
          JSON.dump(object)
        end

        get '/' do
          http_status!(418, content)
        end

      end

      it 'should use the serializer to encode the http_status content' do
        get("/")
        expect(last_response.status).to eq 418
        expect(JSON.load(last_response.body)).to eq(content)
      end
    end

  end
end
