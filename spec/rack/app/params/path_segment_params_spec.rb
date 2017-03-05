# frozen_string_literal: true
require 'spec_helper'
describe Rack::App do
  include Rack::App::Test

  rack_app do
    get '/path_segments_params' do
      YAML.dump(path_segments_params)
    end

    get '/:id/:test/path_segments_params' do
      YAML.dump(path_segments_params)
    end
  end

  let(:original_path) { '/123/321/path_segments_params' }
  let(:path) { original_path }

  describe '#path_segments_params' do
    subject { YAML.load(get(path).body) }

    it { is_expected.to eq 'id' => '123', 'test' => '321' }

    context "when no path_segments_params given in the url" do
      let(:path) { "/path_segments_params" }

      it { is_expected.to eq Hash.new }
    end

    context 'when query string included in the path' do
      let(:path) { original_path + '?hello=world' }

      it { is_expected.to eq 'id' => '123', 'test' => '321' }

      context 'and the query string content has overleaping value to the path_segments' do
        let(:path) { original_path + '?id=1&test=2' }

        it { is_expected.to eq 'id' => '123', 'test' => '321' }
      end
    end
  end
end
