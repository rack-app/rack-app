require 'spec_helper'

describe Rack::App::Router do
  let(:instance) { described_class.new }

  let(:defined_request_path) { '/users/:user_id' }
  let(:received_request_path) { '/users/123' }
  let(:request_method) { 'GET' }

  let(:endpoint) do
    settings = {
        :app_class => Class.new(Rack::App),
        :user_defined_logic => lambda { 'hello world!' },
        :request_method => request_method,
        :request_path => defined_request_path,
        :route => {
           :description => 'desc'
        }
    }
    Rack::App::Endpoint.new(settings)
  end

  describe '#register_endpoint!' do

    subject { instance.register_endpoint!(endpoint) }

    it { is_expected.to be endpoint }

    context 'when dynamic path given' do
      let(:defined_request_path) { '/users/:user_id' }

      it 'should use dynamic router for register the new endpoint' do
        dynamic_router = Rack::App::Router::Dynamic.new
        expect(Rack::App::Router::Dynamic).to receive(:new).and_return(dynamic_router)
        expect(dynamic_router).to receive(:register_endpoint!)

        is_expected.to be nil
      end

    end

    context 'when static path given' do
      let(:defined_request_path) { '/users/user_id' }

      it 'should use dynamic router for register the new endpoint' do
        static_router = Rack::App::Router::Static.new
        expect(Rack::App::Router::Static).to receive(:new).and_return(static_router)
        expect(static_router).to receive(:register_endpoint!)

        is_expected.to be nil
      end

    end

  end

  describe 'merge_router!' do

    let(:router) { described_class.new }
    subject { router.merge_router!(other_router) }

    context 'when not static router given' do
      let(:other_router) { 'nope, this is a string' }

      it { expect { subject }.to raise_error(ArgumentError, /must implement :endpoints interface/) }
    end

  end

  describe '#show_endpoints' do
    subject { instance.show_endpoints }

    require 'rack/app/test'
    include Rack::App::Test
    rack_app

    context 'when endpoint is defined' do
      before { instance.register_endpoint!(endpoint) }

      it { is_expected.to eq ["GET   /users/:user_id   desc"] }
    end

  end

end
