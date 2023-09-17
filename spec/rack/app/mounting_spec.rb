require 'spec_helper'
Dir.glob(File.join(File.dirname(__FILE__), 'mounting_spec', '*.rb')).each { |file_path| require(file_path) }
describe Rack::App do

  require 'rack/app/test'
  include Rack::App::Test

  describe '.mount_rack_app' do

    subject { described_class.mount_rack_app(to_be_mounted_api_class) }

    context 'when valid api class given' do

      rack_app do

        klass = Class.new(Rack::App)
        klass.class_eval do
          get '/endpoint' do
            'mounted endpoint'
          end
        end

        mount_rack_app klass

      end

      it 'should merge the mounted class endpoints to its own collection' do
        expect(get('/endpoint').body).to eq 'mounted endpoint'
      end

    end

    context 'when invalid class given' do

      it 'should raise argument error' do
        expect { rack_app { mount_rack_app('nope this is a string') } }.to raise_error(ArgumentError, 'Invalid class given for mount, must be a Rack::App')
      end

    end

  end

  describe '.mount_rack_interface_compatible_application' do
    context 'when mounting point given' do
      rack_app do

        mount_rack_interface_compatible_application RackBasedApplication

        namespace :mount do

          mount_rack_interface_compatible_application RackBasedApplication, :to => '/point'

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

    context 'when no mount point given' do

      context 'an object with call method support' do
        rack_app do
          mount_rack_interface_compatible_application RackMountTestApp
        end

        Rack::App::Constants::HTTP::METHODS.each do |method_type|
          context "when request method is #{method_type}" do
            ['/','/test','/test/this'].each do |path_info|
              context "when request path is #{path_info}" do
                it { expect(__send_rack_app_request__(method_type, path_info).body).to eq [method_type, path_info].join(':') }
              end
            end
          end
        end
      end

      context 'Rack::Builder' do
        rack_app do

          rica = Rack::Builder.new do
            run(lambda {|env|
              path_info = env[::Rack::App::Constants::ENV::PATH_INFO]
              method_type = env['REQUEST_METHOD']
              Rack::Response.new(method_type + ':' + path_info).finish
            })
          end

          mount rica

        end

        Rack::App::Constants::HTTP::METHODS.each do |method_type|
          context "when request method is #{method_type}" do
            ['/','/test','/test/this'].each do |path_info|
              context "when request path is #{path_info}" do
                it { expect(__send_rack_app_request__(method_type, path_info).body).to eq [method_type, path_info].join(':') }
              end
            end
          end
        end
      end

    end
  end

end
