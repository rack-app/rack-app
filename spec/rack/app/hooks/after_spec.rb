require 'spec_helper'
describe Rack::App do
  include Rack::App::Test

  describe '.after' do
    rack_app do
      def self.queue
        @queue ||= []
      end

      after { self.class.queue << 'after' }
      after do
        if params['break_in_after']
          resp = Rack::Response.new
          resp.write('breaked')
          respond_with(resp)
        end
      end

      get '/' do
        self.class.queue << 'in'

        'OK'
      end
    end

    it 'should be executed after the endpoint definition' do
      expect(get('/').body).to eq 'OK'
      expect(rack_app.queue).to eq %w[in after]
    end

    it { expect(get('/', :params => { 'break_in_after' => true }).body).to eq 'breaked' }
  end
end
