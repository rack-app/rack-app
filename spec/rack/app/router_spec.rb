require 'spec_helper'

describe Rack::App::Router do
  include Rack::App::Test

  let(:router) { rack_app.router }
  rack_app Rack::App do
  end

  describe 'merge_router!' do


    subject { router.merge_router!(other_router) }

    context 'when not static router given' do
      let(:other_router) { 'nope, this is a string' }

      it { expect { subject }.to raise_error(ArgumentError, /must implement :endpoints interface/) }
    end

  end

  describe '#show_endpoints' do
    subject { router.show_endpoints }

    context 'when endpoint is defined' do
      rack_app do
        desc 'desc'
        get '/users/:user_id' do
        end
      end

      it { is_expected.to eq ["GET   /users/:user_id   desc"] }
    end

  end

end
