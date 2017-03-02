require 'spec_helper'
describe 'Params Validation additional tests' do
  include Rack::App::Test

  example_app = Class.new(Rack::App)
  example_app.class_eval do
    desc 'hello world endpoint'
    validate_params do
      required 'words', :class => Array, :of => String,
                        :desc => 'words that will be joined with space',
                        :example => %w(dog cat)

      required 'to', :class => String,
                     :desc => 'the subject of the conversation'
    end
    get '/validated' do
      respond_with "Hello #{validated_params['to']}: #{validated_params['words'].join(' ')}"
    end

    get '/unvalidated' do
      validated_params # > nil
    end
  end

  rack_app example_app

  describe '/validated' do
    let(:params) { {} }
    let(:request) { get(:url => '/validated', :params => params) }

    context 'when required params missing given' do
      before { params.delete('words') }

      it { expect(request.status).to eq 422 }
    end

    context 'when :words given' do
      before { params['words'] = ['Hello', 'world!'] }
      it { expect(request.status).to eq 422 }

      context 'and :to given' do
        before { params['to'] = 'you' }

        it { expect(request.status).to eq 200 }
        it { expect(request.body).to eq 'Hello you: Hello world!' }
      end

    end
  end
end
