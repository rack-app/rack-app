require 'spec_helper'
describe Rack::App do

  require 'rack/app/test'
  include Rack::App::Test

  describe '.on_mounted' do

    mounted_class = Class.new(Rack::App)
    mounted_class.class_eval do

      on_mounted do |options|

        get "/#{options[:endpoint]}" do
          'works'
        end

        options.delete(:to)

      end

      get '/' do
        'hello'
      end

    end

    rack_app do

      get '/' do
        'original'
      end

      mount mounted_class, :to => '/mount_point', :test => 'hello', :endpoint => 'hy'

    end

    it { expect(get(:url => '/').body).to eq 'original' }

    it { expect(get(:url => '/mount_point').body).to eq 'hello' }

    it { expect(get('/mount_point/hy').body).to eq 'works' }

    it 'should NEVER ALLOW any change in the source App class that being mounte, even if dynamic endpoint deceleration included based on the option' do
      expect(Rack::MockRequest.new(mounted_class).get('/hy').status).to eq 404
    end

  end

  describe '.mount' do
    subject { described_class.mount(to_be_mounted_api_class) }

    context 'when valid api class given' do

      let(:to_be_mounted_api_class) do
        klass = Class.new(Rack::App)
        klass.class_eval do

          get '/endpoint' do
            'hello world!'
          end

          on_mounted do |options|

          end

        end
        klass
      end

      it 'should merge the mounted class endpoints to its own collection' do
        is_expected.to be nil

        expect(described_class.router.fetch_endpoint('GET', '/endpoint')).to_not be nil
      end

    end

    context 'when invalid class given' do
      let(:to_be_mounted_api_class) { 'nope this is a string' }

      it 'should raise argument error' do
        expect { subject }.to raise_error(ArgumentError, 'Invalid class given for mount, must be a Rack::App')
      end

    end

  end

end