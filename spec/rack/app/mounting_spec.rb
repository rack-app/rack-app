require 'spec_helper'
Dir.glob(File.join(File.dirname(__FILE__), 'mounting_spec', '*.rb')).each { |file_path| require(file_path) }
describe Rack::App do

  require 'rack/app/test'
  include Rack::App::Test

  describe '.mount' do

    subject { described_class.mount(to_be_mounted_api_class) }

    context 'when valid api class given' do

      rack_app do

        klass = Class.new(Rack::App)
        klass.class_eval do
          get '/endpoint' do
            'mounted endpoint'
          end
        end

        mount klass

      end

      it 'should merge the mounted class endpoints to its own collection' do
        expect(get('/endpoint').body).to eq 'mounted endpoint'
      end

    end

    context 'when invalid class given' do

      it 'should raise argument error' do
        expect { rack_app { mount('nope this is a string') } }.to raise_error(ArgumentError, 'Invalid class given for mount, must be a Rack::App')
      end

    end

  end

  describe '.mount_rack_based_application' do

    rack_app do

      mount_rack_based_application RackBasedApplication

      namespace :mount do

        mount_rack_based_application RackBasedApplication, :to => '/point'

      end

      get '/' do
        'endpoints have bigger priority than mounted applications'
      end

      get '/hello/world/:text' do
        'partially matching endpoint'
      end

    end

    it { expect(get('/').body).to eq 'endpoints have bigger priority than mounted applications' }

    it { expect(get('/hello/world/test/endpoint').body).to eq 'Hello, World!' }
    it { expect(post('/hello/world/test/endpoint').body).to eq 'Hello, World!' }
    it { expect(put('/hello/world/test/endpoint').body).to eq 'Hello, World!' }
    it { expect(delete('/hello/world/test/endpoint').body).to eq 'Hello, World!' }
    it { expect(patch('/hello/world/test/endpoint').body).to eq 'Hello, World!' }
    it { expect(head('/hello/world/test/endpoint').body).to eq 'Hello, World!' }
    it { expect(options('/hello/world/test/endpoint').body).to eq 'Hello, World!' }

    it 'should mount to the correct namespace and mount point' do
      expect(get('/mount/point/hello/world/test/endpoint').body).to eq 'Hello, World!'
    end

    it { expect(get('/hello/world/to_you').body).to eq 'partially matching endpoint' }

  end


end
