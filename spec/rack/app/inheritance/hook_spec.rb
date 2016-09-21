require "spec_helper"
describe Rack::App do
  include Rack::App::Test

  describe '.before' do
    klass = Class.new(described_class)
    klass.class_eval do
      before { @say = 'Hello' }
      before { @word = 'World' }
    end

    rack_app(Class.new(klass)) do

      get '/say' do
        "#{@say}, #{@word}!"
      end

    end

    it { expect(get('/say').body).to eq 'Hello, World!' }
  end

  describe '.after' do
    klass = Class.new(described_class)
    klass.class_eval do
      after { self.class.queue << 'after' }
    end

    rack_app(Class.new(klass)) do

      def self.queue
        @queue ||= []
      end

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
