require 'spec_helper'
describe Rack::App::Endpoint::NOT_FOUND do

  def new_subject
    described_class
  end

  let!(:request_env) { {} }

  describe '.execute' do

    subject { new_subject.execute(request_env) }

    it 'should set the response body to 404 Not Found' do
      expect(subject.last.body.join).to eq '404 Not Found'
    end

    it 'should set the response status to 404' do
      expect(subject.first).to eq 404
    end

  end

end