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
      params['dog']
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

  rack_app RackTEST

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
    subject { get :url => '/params', :params => {'dog' => 'meat'} }

    it { expect(subject.body).to eq 'meat' }
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