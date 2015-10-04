require 'spec_helper'

describe Rack::APP::Router::Static do

  let(:request_path) { '/endpoint/path' }
  let(:request_method) { 'GET' }

  let(:endpoint) do
    Rack::APP::Endpoint.new(Class.new(Rack::APP)) do
      'hello world!'
    end
  end

  describe 'add_endpoint' do
    subject { described_class.new.add_endpoint(request_method, request_path, endpoint) }

    it { is_expected.to be endpoint }
  end

  describe 'fetch_endpoint' do
    let(:router) { described_class.new }
    subject { router.fetch_endpoint(request_method, request_path) }

    context 'when matching route given' do
      before { router.add_endpoint(request_method, request_path, endpoint) }

      it { is_expected.to be endpoint }
    end

    context 'when no matching route given' do
      it { is_expected.to be nil }
    end

  end

  describe 'merge!' do
    let(:router) { described_class.new }
    subject { router.merge!(other_router) }

    context 'when not static router given' do
      let(:other_router) { 'nope, this is a string' }

      it { expect { subject }.to raise_error(ArgumentError, /Rack::APP::Router::Static/) }
    end

    context 'when static router given' do
      let(:other_router) { described_class.new.tap { |r| r.add_endpoint(request_method, request_path, endpoint) } }

      it 'should have all the endpoints that the othere router got' do
        is_expected.to be nil

        expect(router.fetch_endpoint(request_method,request_path)).to be endpoint
      end
    end

  end

end