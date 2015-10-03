require 'spec_helper'
describe Rack::API::Endpoint::NOT_FOUND do

  def new_subject
    described_class
  end

  let!(:request_env) { {} }
  let!(:request) { Rack::Request.new(request_env) }
  let!(:response) { Rack::Response.new }

  before do
    allow(Rack::Request).to receive(:new).with(request_env).and_return(request)
    allow(Rack::Response).to receive(:new).and_return(response)
  end

  describe '.execute' do

    subject { new_subject.execute(request_env) }

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