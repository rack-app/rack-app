# frozen_string_literal: true
require 'spec_helper'
describe Rack::App do
  include Rack::App::Test

  rack_app do

    app = Class.new(Rack::App)
    app.class_eval do
      use SimpleSetterMiddleware, 'test1', 'value1'

      mount RackBasedApplication
    end

    use SimpleSetterMiddleware, 'test2', 'value2'

    mount app

  end

  describe 'mounted app should be using the app middlewares too' do
    it { expect(get('/get_value/test1').body).to eq 'value1' }
    it { expect(get('/get_value/test2').body).to eq 'value2' }
  end
end
