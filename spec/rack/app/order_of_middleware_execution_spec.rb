require "spec_helper"
describe Rack::App do
  include Rack::App::Test

  context 'before hook should be applied after the next_endpoint_middlewares' do
    rack_app do

      def self.last_env(obj=nil)
        @last_env = obj unless obj.nil?
        @last_env
      end

      before do
        request.env['order'] << 'before'
      end

      after do
        request.env['order'] << 'after'
      end

      middlewares do |b|
        b.use SimpleExecMiddleware, lambda{|env| env['order'] << 'middlewares' }
      end

      next_endpoint_middlewares do |b|
        b.use SimpleExecMiddleware, lambda{|env| env['order'] << 'next_endpoint_middlewares' }
      end

      get '/' do
        self.class.last_env(request.env)
      end

    end


    it [
      'should execute middlewares in the correct order:',
      "middlewares first, so any global middleware based auth could cover endpoint",
      "next_endpoint_middlewares than, so any customization for the endpoint can be applied",
      "and finally before and after hooks, so they are can have fully configured request env.",
      "This is due the reason, that middlewares hold usualy auth logic, and everything should be protected under that, and such thing like api interface (params validation) should not be exposed."
    ].join("\n") do
      get('/', :env => { 'order' => [] })
      expected_order = ["middlewares", "next_endpoint_middlewares", "before", "after"]
      expect(rack_app.last_env['order']).to eq expected_order
    end

  end

end
