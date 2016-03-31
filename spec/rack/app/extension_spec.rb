require 'spec_helper'
require File.join(File.dirname(__FILE__), 'extension_spec', 'example-rack_app_extension')
describe Rack::App::Extension do

  require 'rack/app/test'
  include Rack::App::Test

  rack_app do

    extensions :rack_app_extension

    get '/' do
      sup
    end

  end

  it { expect(get('/').body).to eq 'all good thanks!' }

  it { expect(Class.new(rack_app).hello).to eq 'world' }


  context 'when unsupported extension reference given' do

    it 'should raise an error' do
      unsupported_extension_reference = 'unknown'

      expect {
        rack_app { extensions unsupported_extension_reference }
      }.to raise_error("Not registered extension name requested: unknown")
    end

  end

end