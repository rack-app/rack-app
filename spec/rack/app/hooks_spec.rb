require "spec_helper"
describe Rack::App do
  include Rack::App::Test

  describe '.before' do
    rack_app do

      before { @say = 'Hello' }
      before { @word = 'World' }

      get '/say' do
        "#{@say}, #{@word}!"
      end

    end

    it { expect(get('/say').body).to eq 'Hello, World!' }
  end

  describe '.after' do
    rack_app do

      def self.queue
        @queue ||= []
      end

      after { self.class.queue << 'after' }

      get '/' do
        self.class.queue << 'in'

        'OK'
      end

    end

    it 'should be executed after the endpoint definition' do
       expect(get('/').body).to eq 'OK'
       expect(rack_app.queue).to eq %w(in after)
    end
  end

end
