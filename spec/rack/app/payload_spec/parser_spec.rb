require "csv"
require "spec_helper"
describe "Rack::App#payload" do
  include Rack::App::Test

  let(:payload_struct) { [{"Foo" => "bar"}] }

  rack_app do

    payload do
      parser do
        accept :json, :www_form_urlencoded

        on "custom/x-yaml" do |io|
          YAML.load(io.read)
        end
      end
    end

    get "/" do
      Marshal.dump(payload) #> [{"Foo" => "bar"}]
    end

  end

  context 'when custom parser defined' do

    let(:request_options) do
      {
        :env => { Rack::App::Constants::ENV::CONTENT_TYPE => 'custom/x-yaml' },
        :payload => YAML.dump(payload_struct)
      }
    end

    it { expect(Marshal.load(get('/', request_options).body)).to eq payload_struct }
  end

  unless IS_OLD_RUBY
    context 'when payload is a json' do

      [
        "application/json",
        "application/x-javascript",
        "text/javascript",
        "text/x-javascript",
        "text/x-json",
      ].each do |json_content_type|
        context "when json content_type given with: #{json_content_type}" do
          let(:payload){JSON.dump(payload_struct)}

          let(:request_options) do
            {
              :env => { Rack::App::Constants::ENV::CONTENT_TYPE => json_content_type },
              :payload => payload
            }
          end

          it { expect(Marshal.load(get('/', request_options).body)).to eq payload_struct }

          context 'and the payload is not valid' do
            let(:payload){'{"hello":"world"'}

            it{ expect(get('/', request_options).status).to eq 400 }
          end

        end
      end

    end
  end

  context 'when no content type given' do
    let(:request_options) do
      {
        :payload => 'Hello, World!'
      }
    end

    it { expect(Marshal.load(get('/', request_options).body)).to eq 'Hello, World!' }

  #   context "and the :reject_unsupported_media_types flag is set" do
  #     rack_app do
  #       payload do
  #         parser do
  #           accept :json, :www_form_urlencoded
  #
  #           reject_unsupported_media_types
  #         end
  #       end
  #
  #       get "/" do
  #         "happen"
  #
  #         payload
  #
  #         'Never reached...'
  #       end
  #     end
  #
  #     it { expect(get('/', request_options).status).to eq 415 }
  #     it { expect(get('/', request_options).body).to eq "Unsupported Media Type" }
  #   end
  end

  context 'when unknown content type given' do
    let(:request_options) do
      {
        :env => { Rack::App::Constants::ENV::CONTENT_TYPE => 'unknown' },
        :payload => 'Hello, World!'
      }
    end

    it { expect(Marshal.load(get('/', request_options).body)).to eq 'Hello, World!' }
  end

  context 'when content type is form-urlencoded' do
    let(:payload_struct){{'hello' => 'world'}}

    [
      'application/x-www-form-urlencoded'
    ].each do |ct|
      context "when content_type given with: #{ct}" do

        let(:request_options) do
          {
            :env => { Rack::App::Constants::ENV::CONTENT_TYPE => ct },
            :payload => Rack::App::Utils.encode_www_form(payload_struct)
          }
        end

        it { expect(Marshal.load(get('/', request_options).body)).to eq payload_struct }

      end

      context "when content_type given with: #{ct}, and the payload has a 0 char ending (safari browser)" do

        let(:request_options) do
          {
            :env => { Rack::App::Constants::ENV::CONTENT_TYPE => ct },
            :payload => Rack::App::Utils.encode_www_form(payload_struct) + "\u0000"
          }
        end

        it { expect(Marshal.load(get('/', request_options).body)).to eq payload_struct }

      end
    end

  end
end
