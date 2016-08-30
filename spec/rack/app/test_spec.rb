require 'spec_helper'
require 'rack/app/test'

describe Rack::App::Test do

  include Rack::App::Test

  class RackTEST < Rack::App

    get '/hello' do
      response.status = 201
      'world'
    end

    post '/hello' do
      response.status = 202
      'sup?'
    end

    put '/this' do
      'in'
    end

    delete '/destroy' do
      'find'
    end

    get '/headers' do
      request.env['HTTP_X_HEADER']
    end

    get '/params' do
      params['value']
    end

    get '/payload' do
      payload = ''

      while chunk = request.body.gets
        payload += chunk
      end

      payload
    end

    options '/destroy' do
      'options stuff'
    end

  end

  describe '.rack_app' do
    subject{ get('/').body }

    app1 = Class.new(Rack::App)
    app1.class_eval do
      get '/' do
        'app1'
      end
    end

    app2 = Class.new(Rack::App)
    app2.class_eval do
      get '/' do
        'app2'
      end
    end

    context 'when explicitly set' do
      rack_app app1

      it { is_expected.to eq 'app1' }
    end

    context 'when used with block' do
      rack_app do
        get '/' do
          'block'
        end
      end

      it { is_expected.to eq 'block' }
    end

    context 'when nothing given the default is to try use the described_class' do
      let(:described_class){ app2 }

      it { is_expected.to eq 'app2' }
    end

  end

  context 'given we use the example RackTest as our app subject' do
    rack_app RackTEST

    describe 'url in test helpers' do

      context 'as string argument' do
        subject { get('/hello') }

        it { expect(subject.body).to eq 'world' }

        it { expect(subject.status).to eq 201 }
      end

      context 'as hash :url key value' do
        subject { get(:url => '/hello') }

        it { expect(subject.body).to eq 'world' }

        it { expect(subject.status).to eq 201 }
      end


    end

    describe '#get' do

      subject { get(:url => '/hello') }

      it { expect(subject.body).to eq 'world' }
      it { expect(subject.status).to eq 201 }

    end

    describe '#post' do

      subject { post(:url => '/hello') }

      it { expect(subject.body).to eq 'sup?' }
      it { expect(subject.status).to eq 202 }

    end

    describe '#put' do

      subject { put(:url => '/this') }

      it { expect(subject.body).to eq 'in' }
      it { expect(subject.status).to eq 200 }

    end

    describe '#delete' do

      subject { delete(:url => '/destroy') }

      it { expect(subject.body).to eq 'find' }
      it { expect(subject.status).to eq 200 }

    end

    describe '#options' do

      subject { options(:url => '/destroy') }

      it { expect(subject.body).to eq 'options stuff' }
      it { expect(subject.status).to eq 200 }

    end

    describe '#headers' do
      subject { get :url => '/headers', :headers => {'X-Header' => 'cat'} }

      it { expect(subject.body).to eq 'cat' }
    end

    describe '#params' do
      subject { get :url => '/params', :params => {'value' => value} }

      [' ', 'dog', '2016-07-25T20:35:35+02:00'].each do |expected_value|
        context "when value is #{expected_value}" do
          let(:value){ expected_value }

          it { expect(subject.body).to eq expected_value }
        end
      end

    end

    describe '#payload' do
      subject { get :url => '/payload', :payload => "hello\nworld" }

      it { expect(subject.body).to eq "hello\nworld" }
    end

    describe '#env' do
      subject { get :url => '/payload', :env => {'rack.input' => ::Rack::Lint::InputWrapper.new(StringIO.new("hello\nworld"))} }

      it { expect(subject.body).to eq "hello\nworld" }
    end

  end

end
