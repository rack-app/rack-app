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

      context 'with multiple value' do
        before { request[:env][::Rack::QUERY_STRING]= 'a=2&a=3' }

        it { is_expected.to eq({"a" => ["2", "3"]}) }
      end

      context 'when dynamic path given with restful param' do
        before { request[:url]= '/users/123' }

        before { request[:env]= {'rack.app.path_params_matcher' => {2 => 'user_id'}} }

        it { is_expected.to eq({"user_id" => '123'}) }
      end

    end

    context 'when reuqest env do not include any query' do
      before { request[:env]['QUERY_STRING']= '' }

      it { is_expected.to eq({}) }
    end

  end

end
