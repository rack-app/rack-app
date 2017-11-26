require 'spec_helper'

RSpec.describe Rack::App do
  mounted_app = Class.new(Rack::App)
  mounted_app.class_eval do
    before do
      request.env['B'] = 'mounted'
    end

    get('/') { request.env['B'] }
  end

  rack_app do
    before do
      http_status!(401) unless request.env['HTTP_ALLOW_ME'] == 'please'
    end

    before do
      request.env['B'] = 'mounter'
    end

    mount mounted_app
  end

  describe '.before' do
    subject(:response) { get('/', headers: headers) }

    context 'execution order start from the most outside app hooks, and ends with the most inner' do
      let(:headers) { { allow_me: 'please' } }

      it { expect(response.body).to eq 'mounted' }
    end

    context 'given the mounter app set a before block for auth reason' do
      context 'when request  "authenticated"' do
        let(:headers) { { allow_me: 'please' } }

        it { expect(response.status).to eq 200 }
      end

      context 'when request is unsigned' do
        let(:headers) { { allow_me: 'NOW!' } }

        it { expect(response.status).to eq 401 }
      end
    end
  end
end
