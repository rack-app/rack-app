# frozen_string_literal: true

require 'spec_helper'
RSpec.describe Rack::App do
  include Rack::App::Test

  describe '.namespace' do
    describe 'endpoint route path behavior' do
      rack_app do
        namespace '/users' do
          namespace '123' do
            get '/hello' do
              'yep'
            end
          end

          get '/return' do
            respond_with 'hello world'
          end

          class SubController < Rack::App
            get '/test' do
              'hy'
            end
          end

          mount SubController

          mount SubController, :to => 'sub'

          serve_files_from '/spec/fixtures', :to => 'static'
        end
      end

      it { expect(get(:url => '/users/return').body).to eq 'hello world' }

      it { expect(get(:url => '/users/123/hello').body).to eq 'yep' }

      it { expect(get(:url => '/users/test').body).to eq 'hy' }

      it { expect(get(:url => '/users/sub/test').body).to eq 'hy' }

      it { expect(get(:url => '/users/static/raw.txt').body).to eq "hello world!\nhow you doing?" }
    end

    describe 'method return value behavior' do
      subject { rack_app { namespace('/test') } }

      it { is_expected.to eq '/' }

      context 'when with in a namespace definition' do
        subject do
          v = nil
          rack_app do
            namespace '/well' do
              namespace :hello do
                namespace 'there' do
                  v = namespace
                end
              end
            end
          end
          return v
        end

        it { is_expected.to eq '/well/hello/there' }
      end
    end
  end
end
