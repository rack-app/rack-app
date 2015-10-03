require 'spec_helper'
describe Rack::APP do

  let(:described_class) { Class.new(Rack::APP) }
  let(:request_path) { '/some/endpoint/path' }
  let(:block) { Proc.new {} }

  describe '.endpoints' do
    subject { described_class.endpoints }

    it { is_expected.to eq Hash.new }
  end

  [:get, :post, :put, :delete, :patch, :options].each do |http_method|
    describe ".#{http_method}" do

      subject { described_class.public_send(http_method, request_path, &block) }

      let!(:endpoint) { Rack::APP::Endpoint.new(described_class, &block) }
      before do
        allow(Rack::APP::Endpoint).to receive(:new)
                                          .with(
                                              described_class,
                                              {
                                                  request_method: http_method.to_s.upcase,
                                                  request_path: request_path,
                                                  description: nil
                                              }
                                          )
                                          .and_return(endpoint)

      end

      it { is_expected.to be_a Rack::APP::Endpoint }
      it { is_expected.to be endpoint }

      it "should create an endpoint in the endpoint collection" do
        request_key = [http_method.to_s.upcase, request_path]
        is_expected.to be described_class.endpoints[request_key]
      end

    end
  end

  describe '.add_route' do

    let(:http_method) { 'GET' }
    subject { described_class.add_route(http_method, request_path, &block) }

    it { is_expected.to be_a Rack::APP::Endpoint }

    it "should create an endpoint entry under the right request_key based" do
      request_key = [http_method.to_s.upcase, request_path]
      is_expected.to be described_class.endpoints[request_key]
    end

  end

  let(:request_env) { {} }
  let(:request) { Rack::Request.new(request_env) }
  let(:response) { Rack::Response.new }

  def new_subject
    described_class.new(request, response)
  end

  describe '#request' do
    subject { new_subject.request }
    it { is_expected.to be request }
  end

  describe '#response' do
    subject { new_subject.response }
    it { is_expected.to be response }
  end


  describe '#params' do
    subject { new_subject.params }

    context 'when query string given in request env' do

      context 'with single value' do
        before { request_env['QUERY_STRING']= 'a=2' }

        it { is_expected.to eq({"a" => "2"}) }
      end

      context 'with multiple value' do
        before { request_env['QUERY_STRING']= 'a=2&a=3' }

        it { is_expected.to eq({"a" => ["2", "3"]}) }
      end

    end

    context 'when reuqest env do not include any query' do
      before { request_env['QUERY_STRING']= '' }

      it { is_expected.to eq({}) }
    end

  end

  describe '#status' do

    context 'when new status given to be set' do
      subject { new_subject.status }

      it { is_expected.to eq(200) }

      it { is_expected.to be response.status }
    end

    context 'when new status given to be set' do
      subject { new_subject.status(201) }

      it { is_expected.to eq(201) }

      it { is_expected.to be response.status }
    end

  end

  describe '.mount' do
    subject { described_class.mount(to_be_mounted_api_class) }

    context 'when valid api class given' do

      let(:to_be_mounted_api_class) do
        klass = Class.new(Rack::APP)
        klass.class_eval do

          get '/endpoint' do
            'hello world!'
          end

        end
        klass
      end

      it 'should merge the mounted class endpoints to its own collection' do
        is_expected.to be nil

        expect(described_class.endpoints.count).to eq 1
      end

    end

    context 'when invalid class given' do
      let(:to_be_mounted_api_class) { 'nope this is a string' }

      it 'should raise argument error' do
        expect{subject}.to raise_error(ArgumentError,'Invalid class given for mount, must be a Rack::APP')
      end

    end


  end

end