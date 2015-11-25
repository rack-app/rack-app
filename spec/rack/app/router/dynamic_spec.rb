require 'spec_helper'

describe Rack::App::Router::Dynamic do

  let(:defined_request_path) { '/users/:user_id' }
  let(:received_request_path) { '/users/123' }
  let(:request_method) { 'GET' }

  let(:endpoint) do
    Rack::App::Endpoint.new(Class.new(Rack::App)) do
      'hello world!'
    end
  end

  describe 'add_endpoint' do
    subject { described_class.new.add_endpoint(request_method, defined_request_path, endpoint) }

    it { is_expected.to be endpoint }

    it 'should add path params matcher to the endpoint' do
      expect(endpoint).to receive(:register_path_params_matcher).with({2 => 'user_id'})

      is_expected.to be endpoint
    end

  end

  describe 'fetch_endpoint' do
    let(:router) { described_class.new }
    subject { router.fetch_endpoint(request_method, received_request_path) }

    context 'when matching route given' do
      before { router.add_endpoint(request_method, defined_request_path, endpoint) }

      it { is_expected.to be endpoint }
    end

    context 'when no matching route given' do
      it { is_expected.to be nil }
    end

    context 'when multiple path given with partial matching' do
      let(:endpoint2) { endpoint.dup }
      before { router.add_endpoint(request_method, defined_request_path, endpoint) }
      before { router.add_endpoint(request_method, [defined_request_path, 'doc'].join('/'),endpoint2) }

      it { is_expected.to be endpoint }
      it { expect(router.fetch_endpoint(request_method, [received_request_path,'doc'].join('/'))).to be endpoint2 }

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

end