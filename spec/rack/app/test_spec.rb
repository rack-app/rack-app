require_relative '../../spec_helper'
require 'rack/app/test'

describe Rack::App::Test do

  include Rack::App::Test

  class RackTEST < Rack::App

    get '/hello' do
      status 201
      'world'
    end

    post '/hello' do
      status 202
      'sup?'
    end

    put '/this' do
      'in'
    end

    delete '/destroy' do
      'find'
    end

    options '/destroy' do
      'options stuff'
    end

  end

  rack_app RackTEST

  describe '#get' do

    subject{ get('/hello') }

    it { expect(subject.body).to eq ['world']}
    it { expect(subject.status).to eq 201}

  end

  describe '#post' do

    subject{ post('/hello') }

    it { expect(subject.body).to eq ['sup?']}
    it { expect(subject.status).to eq 202}

  end

  describe '#put' do

    subject{ put('/this') }

    it { expect(subject.body).to eq ['in']}
    it { expect(subject.status).to eq 200}

  end

  describe '#delete' do

    subject{ delete('/destroy') }

    it { expect(subject.body).to eq ['find']}
    it { expect(subject.status).to eq 200}

  end

  describe '#options' do

    subject{ options('/destroy') }

    it { expect(subject.body).to eq ['options stuff']}
    it { expect(subject.status).to eq 200}

  end

end