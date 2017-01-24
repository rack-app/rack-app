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

      use SampleMiddleware, "hello", "world"

      get '/BlockMiddlewareTester' do
        request.env['test']
      end

      get '/SampleMiddleware' do
        request.env['hello']
      end
    end

    it { expect(get('/BlockMiddlewareTester').body).to eq 'testing' }
    it { expect(get('/SampleMiddleware').body).to eq 'world' }

  end
end
