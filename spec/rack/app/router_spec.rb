require 'spec_helper'

describe Rack::App::Router do
  let(:instance) { described_class.new }

  let(:defined_request_path) { '/users/:user_id' }
  let(:received_request_path) { '/users/123' }
  let(:request_method) { 'GET' }

  let(:endpoint) do
    Rack::App::Endpoint.new(Class.new(Rack::App)) do
      'hello world!'
    end
  end

  describe 'add_endpoint' do

    subject { instance.add_endpoint(request_method, defined_request_path, endpoint) }

    it { is_expected.to be endpoint }

    context 'when dynamic path given' do
      let(:defined_request_path) { '/users/:user_id' }

      it 'should use dynamic router for register the new endpoint' do
        dynamic_router = Rack::App::Router::Dynamic.new
        expect(Rack::App::Router::Dynamic).to receive(:new).and_return(dynamic_router)
        expect(dynamic_router).to receive(:add_endpoint).and_return(endpoint)

        is_expected.to be endpoint
      end

    end

    context 'when static path given' do
      let(:defined_request_path) { '/users/user_id' }

      it 'should use dynamic router for register the new endpoint' do
        static_router = Rack::App::Router::Static.new
        expect(Rack::App::Router::Static).to receive(:new).and_return(static_router)
        expect(static_router).to receive(:add_endpoint).and_return(endpoint)

        is_expected.to be endpoint
      end

    end

  end

  describe 'fetch_endpoint' do

    let(:router) { described_class.new }
    subject { router.fetch_endpoint(request_method, received_request_path) }

    context 'when matching route given' do
      before { router.add_endpoint(request_method, defined_request_path, endpoint) }

      it { is_expected.to be endpoint }
    end

    context 'when multiple path given with partial matching' do
      let(:endpoint2) { endpoint.dup }
      before { router.add_endpoint(request_method, defined_request_path, endpoint) }
      before { router.add_endpoint(request_method, [defined_request_path, 'doc'].join('/'), endpoint2) }

      it { is_expected.to be endpoint }
      it { expect(router.fetch_endpoint(request_method, [received_request_path, 'doc'].join('/'))).to be endpoint2 }

    end

    context 'when no matching route given' do
      it 'should return not_found default endpoint' do
        is_expected.to be Rack::App::Endpoint::NOT_FOUND
      end
    end

  end

  describe 'merge!' do
    let(:router) { described_class.new }
    subject { router.merge!(other_router) }

    context 'when not static router given' do
      let(:other_router) { 'nope, this is a string' }

      it { expect { subject }.to raise_error(ArgumentError, /#{Regexp.escape(described_class.to_s)}/) }
    end

    context 'when static router given' do
      let(:other_router) { described_class.new.tap { |r| r.add_endpoint(request_method, defined_request_path, endpoint) } }

      it 'should have all the endpoints that the othere router got' do
        is_expected.to be nil

        expect(router.fetch_endpoint(request_method, received_request_path)).to be endpoint
      end
    end

  end

  describe '#endpoint_paths' do
    subject { instance.endpoint_paths }

    require 'rack/app/test'
    include Rack::App::Test
    rack_app

    context 'when static endpoint is defined' do
      let(:endpoint) { Rack::App::Endpoint.new(rack_app, {}, &lambda {}) }
      before { instance.add_endpoint('GET', '/index.html', endpoint) }

      it { is_expected.to eq ["GET\t/index.html"] }
    end

  end

end