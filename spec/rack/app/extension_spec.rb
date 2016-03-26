require 'spec_helper'

class ExampleRackAppExtension < Rack::App::Extension

  module ClassMethods

    def hello
      'hello world'
    end

  end

  module EndpointMethods

    def sup
      'all good thanks!'
    end

  end

  include EndpointMethods

  extend ClassMethods

  on_inheritance do |parent, child|
    child.instance_variable_set(:@dog, 'bark')
  end

end

class SampleAppForExtensionTest < Rack::App

  extensions ExampleRackAppExtension

  get '/' do
    sup
  end

end


describe Rack::App::Extension do
  let(:instance) { described_class }

  require 'rack/app/test'
  include Rack::App::Test

  rack_app SampleAppForExtensionTest do

    get '/' do
      sup
    end

  end

  it { expect(get('/').body).to eq 'all good thanks!' }

  it { expect(rack_app.instance_variable_get(:@dog)).to eq 'bark' }

end