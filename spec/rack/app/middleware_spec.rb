# frozen_string_literal: true
require 'spec_helper'
describe Rack::App do
  require 'rack/app/test'
  include Rack::App::Test

  describe '.use' do
    rack_app do
      use BlockMiddlewareTester, 'test' do
        'testing'
      end

      get '/' do
        request.env['test']
      end
    end

    it { expect(get('/').body).to eq 'testing' }
  end
end
