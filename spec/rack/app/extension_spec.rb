require 'spec_helper'
require File.join(File.dirname(__FILE__),'extension_spec','example-rack_app_extension')
describe Rack::App::Extension do

  require 'rack/app/test'
  include Rack::App::Test

  {
      'when class explicitly used' => Example::RackAppExtension,
      'when used with default generated symbol' => :rack_app_extension
  }.each do |context_message,extension_value|
    context context_message do

      rack_app do

        extensions extension_value

        get '/' do
          sup
        end

      end

      it { expect(get('/').body).to eq 'all good thanks!' }

      it { expect(Class.new(rack_app).hello).to eq 'world'}

    end
  end

  context 'when unsupported extension reference given' do

    it 'should raise an error' do
      unsupported_extension_reference = Object.new

      expect{
        rack_app{ extensions unsupported_extension_reference }
      }.to raise_error("unsupported extension reference: #{unsupported_extension_reference.inspect}")
    end

  end

end