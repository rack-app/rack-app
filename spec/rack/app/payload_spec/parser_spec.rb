require "csv"
require "spec_helper"
describe "Rack::App.payload#formats" do
  include Rack::App::Test

  let(:payload_struct) { [{"Foo" => "bar"}] }

  rack_app do

    get "/" do
      Marshal.dump(payload) #> [{"Foo" => "bar"}]
    end

  end

  context 'when custom parser defined' do
    rack_app do

      payload do

        parser do
          on "custom/x-yaml" do |io|
            YAML.load(io.read)
          end
        end

      end

      get "/" do
        Marshal.dump(payload) #> [{"Foo" => "bar"}]
      end

    end

    let(:request_options) do
      {
        :env => { Rack::App::Constants::ENV::CONTENT_TYPE => 'custom/x-yaml' },
        :payload => YAML.dump(payload_struct)
      }
    end

    it { expect(Marshal.load(get('/', request_options).body)).to eq payload_struct }
  end

  context 'when payload is a yaml' do
    [
      "text/yaml",
      "text/x-yaml",
      "application/yaml",
      "application/x-yaml",
    ].each do |yaml_content_type|
      context "when yaml content_type given with: #{yaml_content_type}" do

        let(:request_options) do
          {
            :env => { Rack::App::Constants::ENV::CONTENT_TYPE => yaml_content_type },
            :payload => YAML.dump(payload_struct)
          }
        end

        it { expect(Marshal.load(get('/', request_options).body)).to eq payload_struct }

      end
    end
  end

  context 'when payload is a csv' do

    let(:payload_struct){ [1,2,3] }

    rack_app do

      get "/" do
        Marshal.dump(payload)
      end

    end

    [
      "text/comma-separated-values",
      "application/csv",
      "text/csv",
    ].each do |content_type|
      context "when yaml content_type given with: #{content_type}" do

        let(:request_options) do
          {
            :env => { Rack::App::Constants::ENV::CONTENT_TYPE => content_type },
            :payload => CSV.generate{|csv| csv << payload_struct }
          }
        end

        it { expect(Marshal.load(get('/', request_options).body)).to eq [['1', '2', '3']] }

      end
    end

  end

  if RUBY_VERSION > '1.8'
    context 'when payload is a json' do
      [
        "application/json",
        "application/x-javascript",
        "text/javascript",
        "text/x-javascript",
        "text/x-json",
      ].each do |json_content_type|
        context "when json content_type given with: #{json_content_type}" do

          let(:request_options) do
            {
              :env => { Rack::App::Constants::ENV::CONTENT_TYPE => json_content_type },
              :payload => JSON.dump(payload_struct)
            }
          end

          it { expect(Marshal.load(get('/', request_options).body)).to eq payload_struct }

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
            :payload => Rack::App::Utils.encode_www_form(payload_struct) +  ?\0
          }
        end

        it { expect(Marshal.load(get('/', request_options).body)).to eq payload_struct }

      end
    end

  end
end
