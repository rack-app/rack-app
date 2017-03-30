# frozen_string_literal: true
require 'spec_helper'
describe Rack::App do
  include Rack::App::Test

  rack_app do
    mount ExampleRackApp, :to => '/mount'

    get '/missing' do
      path_to '/not_exists', :class => ExampleRackApp
    end

    get '/' do
      path_to '/', :class => ExampleRackApp
    end

    get '/s' do
      path_to '/s', :class => ExampleRackApp
    end

    get '/d/:id' do
      path_to '/d/:id', :class => ExampleRackApp
    end

    get '/d/:id/alt1' do
      path_to '/d/:id', :params => {'id' => 321}, :class => ExampleRackApp
    end

    get '/d/:id/alt2' do
      path_to '/d/:id', 'id' => 321, :class => ExampleRackApp
    end

    get '/query' do
      path_to '/d/:id', 'id' => 456, "test" => "hello", "world" => "hy", :class => ExampleRackApp
    end

  end

  describe '#path_to' do
    subject { get(path).body }

    context 'when static path required from an application' do
      context 'for example the / root path' do
        let(:path) { '/' }

        it { is_expected.to eq '/mount' }
      end

      context 'for example the /s path' do
        let(:path) { '/s' }

        it { is_expected.to eq '/mount/s' }
      end
    end

    context 'when dynamic path required from an application' do
      context 'with path params' do
        let(:path) { '/d/123' }

        it { is_expected.to eq '/mount/d/123' }
      end

      context 'with specified params passed as :params options' do
        let(:path) { '/d/123/alt1' }

        it { is_expected.to eq '/mount/d/321' }
      end

      context 'with specified params passed as string keys' do
        let(:path) { '/d/123/alt2' }

        it { is_expected.to eq '/mount/d/321' }
      end
    end

    context 'when path params not include all the passed parameter' do
      let(:path) { '/query' }

      it 'should pass as query string' do
        valid_formats = [
          '/mount/d/456?test=hello&world=hy',
          '/mount/d/456?world=hy&test=hello'
        ]

        expect(valid_formats).to include subject
      end
    end

    context 'when class not specified, the current application class is the default' do
      let(:path) { '/mount/path_to_root' }

      it { is_expected.to eq '/mount' }
    end

    context 'when not existing path requested' do
      let(:path) { '/missing' }

      it { expect{subject}.to raise_error "missing path reference" }
    end
  end
end
