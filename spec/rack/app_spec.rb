require 'spec_helper'
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

  describe '.root' do
    context 'given there is already an endpoint' do

      before do
        described_class.class_eval do

          options '/hello' do
            response.status = 777
          end
          get '/hello' do
            'WORLD'
          end
        end
      end

      it 'should define GET endpoint that point to the given request path\'s endpoint' do
        described_class.root '/hello'

        response = described_class.call({'REQUEST_PATH' => '/', 'REQUEST_METHOD' => 'GET'})
        expect(response.last.body).to eq ['WORLD']
      end

      it 'should define GET endpoint that point to the given request path\'s endpoint' do
        described_class.root '/hello'

        response = described_class.call({'REQUEST_PATH' => '/', 'REQUEST_METHOD' => 'OPTIONS'})
        expect(response.last.status).to eq 777
      end

    end
  end

  # describe '.add_route' do
  #
  #   let(:http_method) { 'GET' }
  #   subject { described_class.add_route(http_method, request_path, &block) }
  #
  #   it { is_expected.to be_a Rack::App::Endpoint }
  #
  #   it "should create an endpoint entry under the right request_key based" do
  #     is_expected.to be described_class.router.fetch_endpoint(http_method.to_s.upcase, request_path)
  #   end
  #
  # end

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
      subject{ get(:url => '/handled_exception2') }

      it { expect(subject.body.join).to eq 'standard' }

      it { expect(subject.status).to eq 400 }
    end

    context 'when one of the unhandled exception happen in the endpoint' do
      it { expect { get(:url => '/unhandled_exception') }.to raise_error(Exception, 'unhandled') }
    end

  end

  describe '.header' do

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

    it {  expect(get(:url => '/Access-Control-Allow-Origin').body.join).to eq '*'  }

    it {  expect(get(:url => '/Access-Control-Expose-Headers').body.join).to eq 'X-My-Custom-Header, X-Another-Custom-Header'  }

  end

end