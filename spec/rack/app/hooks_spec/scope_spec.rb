require "spec_helper"
describe Rack::App do
  include Rack::App::Test

  describe 'hook must run in the context where they are being defined' do

    class A < Rack::App

      get "/" do
        "Hello, world!"
      end

    end

    class B < Rack::App
      before { my_instance_method }
      before { @x = true }
      before { raise unless @x }

      def my_instance_method() end

      mount A, to: "/x"
    end

    rack_app B

    it { expect(get('/x').body).to eq "Hello, world!" }

  end

end
