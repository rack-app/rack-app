require 'spec_helper'
describe Rack::App::Endpoint::NOT_FOUND do

  def new_subject
    described_class
  end

  let!(:request_env) { {} }

  describe '.call' do

    subject { ::Rack::MockRequest.new(new_subject).get('/no_such_page_here') }

    it 'should set the response body to 404 Not Found' do
      expect(subject.body).to eq '404 Not Found'
    end

    it 'should set the response status to 404' do
      expect(subject.status).to eq 404
    end

  end

end