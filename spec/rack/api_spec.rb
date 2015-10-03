require 'spec_helper'
describe Rack::API do

  let(:described_class) { Class.new(Rack::API) }
  let(:request_path) { '/some/endpoint/path' }
  let(:block) { Proc.new {} }

  describe '.endpoints' do
    subject { described_class.endpoints }

    it { is_expected.to eq Hash.new }
  end

  [:get, :post, :put, :delete, :patch, :options].each do |http_method|
    describe ".#{http_method}" do

      subject { described_class.public_send(http_method, request_path, &block) }

      it { is_expected.to be_a Proc }
      it { is_expected.to be block }

      it "should create an endpoint in the endpoint collection" do
        request_key = [http_method.to_s.upcase, request_path]
        is_expected.to be described_class.endpoints[request_key]
      end

    end
  end

  describe '.add_route' do

    let(:http_method) { 'GET' }
    subject { described_class.add_route(http_method, request_path, &block) }

    it { is_expected.to be block }

    it "should create an endpoint entry under the right request_key based" do
      request_key = [http_method.to_s.upcase, request_path]
      is_expected.to be described_class.endpoints[request_key]
    end

  end

  let(:request) { Rack::Request.new({}) }
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


  describe '#request_path_not_found' do
    subject{ new_subject.request_path_not_found }

    it 'should set the response body to 404 Not Found' do
      expect(response).to receive(:write).with('404 Not Found')

      subject
    end

    it 'should set the response status to 404' do
      expect(response).to receive(:status=).with(404)

      subject
    end

    it 'should mark response to be finished' do
      finished_response = []

      expect(response).to receive(:finish).and_return(finished_response)

      is_expected.to be finished_response
    end

  end

end