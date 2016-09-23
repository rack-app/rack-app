require "spec_helper"
describe Rack::App do
  include Rack::App::Test

  describe 'hook with http_status! method control flow break' do

    rack_app do
      before do
        http_status!(418)
      end

      get '/' do
        "sorry I'm a teapot, can't serve this"
      end
    end

    it { expect(get('/').status).to eq 418 }
    it { expect(get('/').body).to eq "I'm a teapot (RFC 2324)" }

  end

  describe '.before' do
    rack_app do

      before do
        response.status = 201
        response.write('before')
        finish!
      end

      get '/say' do
        "never happen!"
      end

    end

    it { expect(get('/say').body).to eq 'before' }
  end

  describe '.after' do
    rack_app do

      def self.queue
        @queue ||= []
      end

      after do
        new_response = Rack::Response.new
        new_response.status = 201
        new_response.write('after')
        finish!(new_response)
      end

      get '/say' do
        self.class.queue << "happen but ignored in response"
        self.class.queue.last
      end

    end

    it do
      expect(get('/say').body).to eq 'after'
      expect(rack_app.queue.last).to eq "happen but ignored in response"
    end

  end

end
