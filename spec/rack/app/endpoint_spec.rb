require 'spec_helper'

describe Rack::App::Endpoint do

  let(:app_class) { Class.new(Rack::App) }
  let(:logic_block) { Proc.new { 'hello world!' } }

  let(:properties) do
    {
        :user_defined_logic => logic_block,
        :default_headers => {},
        :request_method => 'GET',
        :error_handler => ::Rack::App::ErrorHandler.new,
        :request_path => '/endpoint/path',
        :description => 'sample description for the endpoint',
        :serializer => Rack::App::Serializer.new{ |object| object.inspect },
        :app_class => app_class
    }
  end

  def new_subject
    described_class.new(properties)
  end

  let(:request_env) { {} }

  describe '#call' do

    subject { new_subject.call(request_env) }
    body_content = [{:id => 1}]

    context 'when endpoint logic writes respond body already' do
      let(:logic_block) { lambda { response.write(' -> '); body_content } }

      it { expect(subject[2].body.join).to eq ' -> [{:id=>1}]' }
    end

    context 'when endpoint logic does not write directly to response body' do
      let(:logic_block) { lambda { body_content } }

      it "uses the block's serialized return value as response payload" do
        expect(subject[2].body[0]).to eq '[{:id=>1}]'
      end
    end

  end

  describe '#properties' do
    subject { new_subject.properties }

    it { is_expected.to eq properties }
  end

end
