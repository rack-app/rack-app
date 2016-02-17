require 'spec_helper'

describe Rack::App::Router::Static do

  let(:request_path) { '/endpoint/path' }
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

  let(:instance) { described_class.new }

  describe '#register_endpoint!' do
    subject { instance.register_endpoint!(request_method, request_path, 'desc', endpoint) }

    it { is_expected.to be endpoint }
  end

  describe 'fetch_endpoint' do
    let(:router) { described_class.new }
    subject { router.fetch_endpoint(request_method, request_path) }

    context 'when matching route given' do
      before { router.register_endpoint!(request_method, request_path, 'desc', endpoint) }

      it { is_expected.to be endpoint }
    end

    context 'when no matching route given' do
      it { is_expected.to be nil }
    end

  end

  describe '#endpoints' do
    subject { instance.endpoints }

    it { is_expected.to eq([]) }

    context 'when endpoint is defined' do
      before { instance.register_endpoint!('GET', '/index.html','desc', endpoint) }

      it { is_expected.to eq([{:request_method => 'GET', :request_path => '/index.html', :description => 'desc', :endpoint => endpoint}]) }
    end
  end

end