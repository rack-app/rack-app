# frozen_string_literal: true
require 'spec_helper'
describe Rack::App do
  include Rack::App::Test

  rack_app do
    use SimpleSetterMiddleware, 'test', 'value'

    mount RackBasedApplication
  end

  describe 'mounted app should be using the app middlewares too' do
    subject { get('/get_value/test').body }

    it { is_expected.to eq 'value' }
  end
end
