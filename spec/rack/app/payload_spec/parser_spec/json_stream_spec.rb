require 'spec_helper'
describe 'Rack::App#payload' do
  require "json"
  include Rack::App::Test

  let(:payload_struct) { [{ 'Foo' => 'bar' }] }

  rack_app do

    payload do
      configure_parser do
        accept :json_stream
        reject_unsupported_media_types
      end
    end

    get '/Marshal' do
      arr = []
      payload.each.with_index do |o, i|
        arr.push({:index => i, :object => o})
      end
      Marshal.dump(arr)
    end
  end

  let(:events) do
    [
      {"hello" => "world"},
      {"how" => "you doing?"}
    ]
  end

  let(:stream) do
    events.map{|e| JSON.dump(e) }.join("\n")
  end

  let(:request_options) do
    {
      :url => '/Marshal',
      :env => { Rack::App::Constants::ENV::CONTENT_TYPE => content_type },
      :payload => stream
    }
  end

  [
    "application/jsonstream",
    "application/stream+json",
    "application/x-json-stream"
  ].each do |ct|
    context "when content type is #{ct}" do
      let(:content_type){ct}

      it "should create an enumerable request stream object that yield the parsed content" do

        expected = events.map.with_index do |o, i|
          {:index => i, :object => o}
        end

        expect(Marshal.load(get(request_options).body)).to match_array expected

      end
    end
  end

end unless IS_OLD_RUBY
