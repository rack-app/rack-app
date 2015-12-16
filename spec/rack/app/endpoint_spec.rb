require 'spec_helper'
require 'json'
describe Rack::App::Endpoint do

  let(:api_class) { Class.new(Rack::App) }
  let(:properties) do
    {
        :request_method => 'GET',
        :request_path => '/endpoint/path',
        :description => 'sample description for the endpoint',
        :serializer => lambda { |object| JSON.dump object }
    }
  end
  let(:logic_block) { Proc.new { 'hello world!' } }

  def new_subject
    described_class.new(api_class, properties, &logic_block)
  end

  let(:request_env) { {} }

  describe '#execute' do

    subject { new_subject.execute(request_env) }
    body_content = [{:id => 1}]

    context 'when endpoint logic writes respond body already' do
      let(:logic_block) { lambda { response.write(body_content) } }

      it { expect(subject[2].body[0]).to eq '[{:id=>1}]' }
    end

    context 'when endpoint logic does not write directly to response body' do
      let(:logic_block) { lambda { body_content } }

      it "uses the block's serialized return value as response payload" do
        expect(subject[2].body[0]).to eq '[{"id":1}]'
      end
    end

    context 'when finish response, it should not take any more action than' do
      let(:logic_block) { lambda { response.finish } }

      it 'should use the block stringified return value as response payload' do
        expect(subject[2].body[0]).to be nil
      end
    end

  end

  describe '#register_path_params_matcher' do
    let(:params_matcher) { {} }
    subject { new_subject.register_path_params_matcher(params_matcher) }

    it { is_expected.to eq params_matcher }
  end

  describe '#properties' do
    subject { new_subject.properties }

    it { is_expected.to eq properties }
  end

end