# frozen_string_literal: true
require 'spec_helper'
describe Rack::App do
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

  paths.each do |path|
    context "when the path is #{path}" do
      rack_app do

        formats do
          on '.yaml', 'application/x-yaml' do |obj|
            YAML.dump(obj)
          end
        end

        get path do
          path
        end

      end

      describe 'versioned paths' do
        it "should work with #{path}" do
          expect(get(path).body).to eq path
        end

        context 'when path called with expected registered response serialization (yaml for example)' do
          let(:path_info) { path + '.yaml' }
          it "should work with #{path}" do
            expect(get(path_info).body).to eq YAML.dump(path)
          end
        end
      end
    end
  end
end
