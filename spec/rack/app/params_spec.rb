require "yaml"
require "spec_helper"
describe Rack::App do

  require 'rack/app/test'
  include Rack::App::Test
  rack_app

  let(:request) { Rack::Request.new(request_env) }

  describe '#params' do

    require 'yaml'

    rack_app do

      get '/params' do
        YAML.dump(params)
      end

      get '/users/:user_id' do
        YAML.dump(params)
      end

      get '/domain/:addr' do
        YAML.dump(params)
      end

    end

    let(:request) { {:url => '/params', :env => {}} }

    subject { YAML.load(get(request).body) }

    context 'when query string given in request env' do

      context 'with single value' do
        before { request[:params]= {'a' => 2} }

        it { is_expected.to eq({"a" => "2"}) }
      end

      context 'with single value and brackets notation' do
        before { request[:params]= {'a[]' => 2} }

        it { is_expected.to eq({"a" => ["2"]}) }
      end

      context 'with array value' do
        before { request[:env][::Rack::QUERY_STRING]= 'a[]=2&a[]=3' }

        it { is_expected.to eq({"a" => ["2", "3"]}) }
      end

      context 'with hash value' do
        before { request[:env][::Rack::QUERY_STRING] = 'a[b]=1&a[c]=2' }

        it { is_expected.to eq({ "a" => { "b" => "1", "c" => "2" } }) }
      end

      context 'with multiple value' do
        before { request[:env][::Rack::QUERY_STRING]= 'a=2&a=3' }

        it { is_expected.to eq({"a" => ["2", "3"]}) }
      end

      context 'when dynamic path given with restful param' do
        before { request[:url]= '/users/123' }

        it { is_expected.to eq({"user_id" => '123'}) }

        context 'and the dynamic path part include dot' do
          before { request[:url]= '/domain/example.com' }

          context 'and that "extension" has no unserializer defined' do
            it { is_expected.to eq({"addr" => 'example.com'}) }
          end

          context 'and that "extension" has unserializer defined' do
            it("is specified in the formats_spec") {}
          end
        end
      end

    end

    context 'when reuqest env do not include any query' do
      before { request[:env]['QUERY_STRING']= '' }

      it { is_expected.to eq({}) }
    end

  end

end
