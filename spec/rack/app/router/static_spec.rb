require 'spec_helper'

describe Rack::App::Router::Static do

  let(:request_path) { '/endpoint/path' }
  let(:request_method) { 'GET' }

  let(:endpoint) do
    settings = {
        :app_class => Class.new(Rack::App),
        :user_defined_logic => lambda { 'hello world!' },
        :request_method => 'GET',
        :request_path => '/index.html',
        :route => {
          :description => 'desc'
        }
    }
    Rack::App::Endpoint.new(settings)
  end

  let(:instance) { described_class.new }
  
  describe '#endpoints' do
    subject { instance.endpoints }

    it { is_expected.to eq([]) }

    context 'when endpoint is defined' do
      before { instance.register_endpoint!(endpoint) }

      it { is_expected.to eq([endpoint]) }
    end
  end

end
