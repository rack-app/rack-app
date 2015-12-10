require 'spec_helper'

describe Rack::App::Router::Static do

  let(:request_path) { '/endpoint/path' }
  let(:request_method) { 'GET' }

  let(:endpoint) do
    Rack::App::Endpoint.new(Class.new(Rack::App)) do
      'hello world!'
    end
  end

  let(:instance) { described_class.new }

  describe 'add_endpoint' do
    subject { instance.add_endpoint(request_method, request_path, endpoint) }

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

      it { expect { subject }.to raise_error(ArgumentError, /Rack::App::Router::Static/) }
    end

    context 'when static router given' do
      let(:other_router) { described_class.new.tap { |r| r.add_endpoint(request_method, request_path, endpoint) } }

      it 'should have all the endpoints that the othere router got' do
        is_expected.to be nil

        expect(router.fetch_endpoint(request_method, request_path)).to be endpoint
      end
    end

  end

  describe '#endpoints' do
    subject { instance.endpoints }

    it { is_expected.to eq({}) }

    context 'when endpoint is defined' do
      let(:endpoint) { Rack::App::Endpoint.new(nil, {}, &-> {}) }
      before { instance.add_endpoint('GET', '/index.html', endpoint) }

      it { is_expected.to eq({['GET', '/index.html'] => endpoint}) }
    end
  end

end