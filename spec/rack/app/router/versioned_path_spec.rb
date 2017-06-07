require 'spec_helper'

RSpec.describe Rack::App do
  include Rack::App::Test

  paths = [
    '/1.0.0',
    '/v1.0.0',
    '/api/v1.0.0',
    '/api/version/1.0.0',
    '/api/v1.0.0/anything',
    '/api/v1.0.0-alpha2/anything',
    '/api/version/1.0.0/anything',
    '/api/v1.0.0/anything/plus_more',
    '/api/version/1.0.0/anything/plus_more'
  ].freeze

  rack_app do
    formats do
      on '.yaml', 'application/x-yaml' do |obj|
        YAML.dump(obj)
      end
    end

    paths.each do |path|
      get path do
        path
      end
    end
  end

  describe 'versioned path parts are in the path_info' do
    subject(:the_response_body) { get(path_info).body }

    paths.each do |path|
      context "when the path is #{path}" do
        let(:path_info) { path }

        it "should work with #{path}" do
          is_expected.to eq path
        end

        context 'when path called with expected registered response serialization (yaml for example)' do
          let(:path_info) { path + '.yaml' }

          it "should work with #{path}" do
            is_expected.to eq YAML.dump(path)
          end
        end
      end
    end
  end
end
