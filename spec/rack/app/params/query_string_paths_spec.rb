# frozen_string_literal: true
require 'spec_helper'
describe Rack::App do
  include Rack::App::Test

  rack_app do
    get '/query_string_params' do
      YAML.dump(query_string_params)
    end

    get '/:id/:test/query_string_params' do
      YAML.dump(query_string_params)
    end
  end

  let(:original_path) { '/123/321/query_string_params' }
  let(:path) { original_path }

  describe '#query_string_params' do
    subject { YAML.load(get(path).body) }

    context "when no query_string_params given in the url" do
      let(:path) { "/query_string_params" }

      it { is_expected.to eq Hash.new }

      context "but there are path segments params" do
        let(:path) { original_path }

        it { is_expected.to eq Hash.new }
      end
    end

    context 'when query string included in the path' do
      let(:path) { original_path + '?hello=world' }

      it { is_expected.to eq 'hello' => 'world' }

      context 'and the query string content has overleaping value to the path_segments' do
        let(:path) { original_path + '?id=1&test=2' }

        it { is_expected.to eq 'id' => '1', 'test' => '2' }
      end
    end
  end
end
