require 'spec_helper'

describe Rack::App::Router::Dynamic do

  let(:defined_request_path) { '/users/:user_id' }
  let(:received_request_path) { '/users/123' }
  let(:request_method) { 'GET' }

  let(:endpoint) do
    settings = {
        :app_class => Class.new(Rack::App),
        :user_defined_logic => lambda { 'hello world!' },
        :request_method => 'GET',
        :request_path => '\404'
    }
    Rack::App::Endpoint.new(settings)
  end

  describe '#register_endpoint!' do
    subject { described_class.new.register_endpoint!(request_method, defined_request_path, 'desc', endpoint) }

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
      before { router.register_endpoint!(request_method, defined_request_path,'desc', endpoint) }

      it { is_expected.to be endpoint }
    end

    context 'when no matching route given' do
      it { is_expected.to be nil }
    end

    context 'when multiple path given with partial matching' do
      let(:endpoint2) { endpoint.dup }
      before { router.register_endpoint!(request_method, defined_request_path,'desc', endpoint) }
      before { router.register_endpoint!(request_method, [defined_request_path, 'doc'].join('/'),'desc', endpoint2) }

      it { is_expected.to be endpoint }
      it { expect(router.fetch_endpoint(request_method, [received_request_path, 'doc'].join('/'))).to be endpoint2 }

    end

    context 'when partial matching is defined' do
      before { router.register_endpoint!(request_method, '/assets/**/*','desc', endpoint) }

      context 'and the received request is targeting the partial match highest layer' do
        let(:received_request_path) { '/assets/some.js' }

        it { is_expected.to be endpoint }
      end

      context 'and the received request is targeting the partial match deep layer' do
        let(:received_request_path) { '/assets/some/folder/to/deal/with/some.js' }

        it { is_expected.to be endpoint }
      end

    end

  end

end