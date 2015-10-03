require 'spec_helper'
describe Rack::API::Endpoint do

  let(:request_method) { 'GET' }
  let(:request_path) { '/endpoint/path' }
  let(:description) { 'sample description for the endpoint' }
  let(:api_class) { Class.new(Rack::API) }
  let(:logic_block) { Proc.new { 'hello world!' } }

  def new_subject
    described_class.new(
        api_class,
        {
            request_method: request_method,
            request_path: request_path,
            description: description
        },
        &logic_block
    )
  end

  let(:request_env) { {} }

  describe '#execute' do

    subject { new_subject.execute(request_env) }

    context 'when endpoint logic writes respond body already' do
      let(:logic_block) { -> { response.write('hello world') } }

      it { expect(subject[2].body[0]).to eq 'hello world' }
    end

    context 'when endpoint logic not writes directly response body' do
      let(:logic_block) { -> { 'hello world' } }

      it 'should use the block stringified return value as response payload' do
        expect(subject[2].body[0]).to eq 'hello world'
      end
    end

    context 'when finish response, it should not take any more action than' do
      let(:logic_block) { -> { response.finish } }

      it 'should use the block stringified return value as response payload' do
        expect(subject[2].body[0]).to be nil
      end
    end

  end

end