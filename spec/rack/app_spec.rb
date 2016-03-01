require 'spec_helper'

class SampleMiddleware
  def initialize(app,k,v)
    @stack = app
    @k,@v = k,v
  end

  def call(env)
    env[@k.dup]= @v.dup
    @stack.call(env)
  end
end

describe Rack::App do

  let(:described_class) { Class.new(Rack::App) }
  let(:request_path) { '/some/endpoint/path' }
  let(:block) { Proc.new {} }

  describe '.router' do
    subject { described_class.router }

    it { is_expected.to be_a Rack::App::Router }
  end

  require 'rack/app/test'
  include Rack::App::Test
  rack_app described_class

  [:get, :post, :put, :delete, :patch, :options].each do |http_method|
    describe ".#{http_method}" do

      rack_app described_class do

        send http_method, "/hello_#{http_method}" do
          String(http_method)
        end

      end

      subject { send(http_method, {:url => "/hello_#{http_method}"}) }

      it { expect(subject.body).to eq [String(http_method)] }

    end
  end

  let(:request_env) { {} }
  let(:request) { Rack::Request.new(request_env) }
  let(:response) { Rack::Response.new }

  let(:new_subject) {
    instance = described_class.new
    instance.request = request
    instance.response = response
    instance
  }

  describe '#request' do
    subject { new_subject.request }
    context 'when request is set' do
      before { new_subject.request = request }

      it { is_expected.to be request }
    end

    context 'when request is not set' do
      before { new_subject.request = nil }

      it { expect { subject }.to raise_error("request object is not set for #{described_class}") }
    end

  end

  describe '#response' do
    subject { new_subject.response }
    context 'when request is set' do
      before { new_subject.response = response }

      it { is_expected.to be response }
    end

    context 'when request is not set' do
      before { new_subject.response = nil }

      it { expect { subject }.to raise_error("response object is not set for #{described_class}") }
    end

  end

  describe '#response' do
    subject { new_subject.response }
    it { is_expected.to be response }
  end


  describe '#params' do
    subject { new_subject.params }

    context 'when query string given in request env' do

      context 'with single value' do
        before { request_env['QUERY_STRING']= 'a=2' }

        it { is_expected.to eq({"a" => "2"}) }
      end

      context 'with array value' do
        before { request_env['QUERY_STRING']= 'a[]=2&a[]=3' }

        it { is_expected.to eq({"a" => ["2", "3"]}) }
      end

      context 'with multiple value' do
        before { request_env['QUERY_STRING']= 'a=2&a=3' }

        it { is_expected.to eq({"a" => ["2", "3"]}) }
      end

      context 'when dynamic path given with restful param' do
        subject { new_subject.params }

        before { request_env['REQUEST_PATH']='/users/123' }
        before { request_env['rack.app.path_params_matcher']= {2 => 'user_id'} }

        before do
          described_class.class_eval do

            get '/users/:user_id' do
              params['user_id']
            end

          end
        end

        it { is_expected.to eq({"user_id" => '123'}) }

      end


    end

    context 'when reuqest env do not include any query' do
      before { request_env['QUERY_STRING']= '' }

      it { is_expected.to eq({}) }
    end

  end

  describe '#payload' do
    subject { new_subject.payload }

    context 'when payload is present in the request env' do
      before { request_env['rack.input']= ::Rack::Lint::InputWrapper.new(StringIO.new("hello\nworld")) }

      it { is_expected.to eq "hello\nworld" }
    end

    context 'when payload is not included in the request env' do
      it { is_expected.to eq nil }
    end

  end

  describe '.mount' do
    subject { described_class.mount(to_be_mounted_api_class) }

    context 'when valid api class given' do

      let(:to_be_mounted_api_class) do
        klass = Class.new(Rack::App)
        klass.class_eval do

          get '/endpoint' do
            'hello world!'
          end

        end
        klass
      end

      it 'should merge the mounted class endpoints to its own collection' do
        is_expected.to be nil

        expect(described_class.router.fetch_endpoint('GET', '/endpoint')).to_not be nil
      end

    end

    context 'when invalid class given' do
      let(:to_be_mounted_api_class) { 'nope this is a string' }

      it 'should raise argument error' do
        expect { subject }.to raise_error(ArgumentError, 'Invalid class given for mount, must be a Rack::App')
      end

    end


  end

  describe '.call' do

    let(:request_method) { 'GET' }
    let(:request_path) { '/hello' }

    let(:request_env) do
      {
          'REQUEST_METHOD' => request_method,
          'REQUEST_PATH' => request_path
      }
    end

    let(:api_class) do
      klass = Class.new(described_class)

      klass.class_eval do

        get '/hello' do
          response.status = 201

          'valid_endpoint'
        end

      end

      klass
    end

    describe '#response_for' do
      subject { api_class.call(request_env) }

      let(:response_body) { subject[2].body[0] }
      let(:response_status) { subject[2].status }

      context 'when there is a valid endpoint for the request' do
        it { expect(response_body).to eq 'valid_endpoint' }

        it { expect(response_status).to eq 201 }
      end

      context 'when there is no endpoint registered for the given request' do
        before { request_env['REQUEST_PATH']= '/unknown/endpoint/path' }

        it { expect(response_body).to eq '404 Not Found' }

        it { expect(response_status).to eq 404 }
      end

    end

  end

  describe '.serializer' do

    context 'when no serializer defined' do

      rack_app described_class do

        get '/serialized' do
          'to_s'
        end

      end

      it { expect(get(:url => '/serialized').body.join).to eq 'to_s' }

    end

    context 'when serializer is defined' do

      rack_app described_class do

        serializer do |o|
          o.inspect.upcase
        end

        get '/serialized' do
          {:hello => :world}
        end

      end

      it { expect(get(:url => '/serialized').body.join).to eq '{:HELLO=>:WORLD}' }

    end

  end


  describe '.error' do

    rack_app described_class do

      error ArgumentError, RangeError do |ex|
        ex.message
      end

      error StandardError do |ex|
        response.status = 400
        'standard'
      end

      get '/handled_exception1' do
        raise(RangeError, 'range')
      end

      get '/handled_exception2' do
        raise(NoMethodError, 'arg')
      end

      get '/unhandled_exception' do
        raise(Exception, 'unhandled')
      end

    end

    context 'when expected error class raised' do
      it { expect(get(:url => '/handled_exception1').body.join).to eq 'range' }
    end

    context 'when a subclass of the expected error class raised' do
      subject { get(:url => '/handled_exception2') }

      it { expect(subject.body.join).to eq 'standard' }

      it { expect(subject.status).to eq 400 }
    end

    context 'when one of the unhandled exception happen in the endpoint' do
      it { expect { get(:url => '/unhandled_exception') }.to raise_error(Exception, 'unhandled') }
    end

  end

  describe '.headers' do

    rack_app described_class do

      headers 'Access-Control-Allow-Origin' => '*',
              'Access-Control-Expose-Headers' => 'X-My-Custom-Header, X-Another-Custom-Header'


      get '/Access-Control-Allow-Origin' do
        response.header['Access-Control-Allow-Origin']
      end

      get '/Access-Control-Expose-Headers' do
        response.header['Access-Control-Expose-Headers']
      end

    end

    it { expect(get(:url => '/Access-Control-Allow-Origin').body.join).to eq '*' }

    it { expect(get(:url => '/Access-Control-Expose-Headers').body.join).to eq 'X-My-Custom-Header, X-Another-Custom-Header' }

  end

  describe 'return works in the endpoint block definition' do

    rack_app described_class do

      get '/return' do
        return 'hello world'

        'not happen'
      end

    end

    it { expect(get(:url => '/return').body.join).to eq 'hello world' }

  end

  describe '.namespace' do

    rack_app described_class do

      namespace '/users' do

        namespace '123' do
          get '/hello' do
            'yep'
          end
        end

        get '/return' do
          return 'hello world'
        end

        class SubController < Rack::App

          get '/test' do
            'hy'
          end

        end

        mount SubController

        mount SubController, :to => 'sub'

        serve_files_from '/spec/fixtures', :to => 'static'

      end

    end

    it { expect(get(:url => '/users/return').body.join).to eq 'hello world' }

    it { expect(get(:url => '/users/123/hello').body.join).to eq 'yep' }

    it { expect(get(:url => '/users/test').body.join).to eq 'hy' }

    it { expect(get(:url => '/users/sub/test').body.join).to eq 'hy' }

    it { expect(get(:url => '/users/static/raw.txt')).to be_a ::Rack::File }

  end

  describe '.serve_files_from' do

    rack_app described_class do

      serve_files_from '/spec/fixtures'

    end

    it { expect(get(:url => '/raw.txt')).to be_a ::Rack::File }

    it 'should return an object which responds to each' do

      response = get(:url => '/raw.txt')

      content = ''
      response.each { |line| content << line }

      expect(content).to eq "hello world!\nhow you doing?"

    end

  end

  describe '.middlewares' do
    subject { rack_app.middlewares }

    rack_app described_class do

      get '/before_middlewares' do
        request.env['custom']
      end

      middlewares do |builder|

        builder.use(SampleMiddleware,'custom','value')

      end

      get '/after_middlewares' do
        request.env['custom']
      end

    end

    it { expect(subject).to be_a Array }

    it { expect(get(:url => '/before_middlewares').body.join).to eq '' }

    it { expect(get(:url => '/after_middlewares').body.join).to eq 'value' }

  end

  describe '.on_mounted' do

    mounted_class = Class.new(Rack::App)
    mounted_class.class_eval do

      on_mounted do |class_who_mount_us, options|

        class_who_mount_us.middlewares do |builder|
          builder.use(SampleMiddleware,'inject',options[:test])
        end

      end

    end

    rack_app do
      mount mounted_class, :to => '/mount_point', :test => 'hello'

      get '/' do
        request.env['inject']
      end

    end

    it { expect(get(:url => '/').body.join).to eq 'hello' }

  end

end