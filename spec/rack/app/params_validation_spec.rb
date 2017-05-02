require 'spec_helper'
describe Rack::App do
  let(:params) { {} }
  require 'rack/app/test'
  include Rack::App::Test

  describe '.validate_params' do
    rack_app do
      desc 'validated endpoint with params'
      validate_params do
        required 'dogs', :class => Array, :of => String, :desc => 'dog names', :example => ['pug']
        optional 'numbers', :class => Array, :of => Integer, :desc => 'some number'
        optional :number, :class => Integer, :desc => 'one number alone'
        optional 'numeric', :class => Numeric
      end
      get '/validated' do
        'OK'
      end

      get '/unvalidated' do
        'OK'
      end
    end

    let(:request) { get(:url => request_path, :params => params) }

    context "when endpoint doesn't have params validation" do
      let(:request_path) { '/unvalidated' }

      context 'and no params given' do
        it { expect(request.status).to eq 200 }
      end

      context 'and some params given' do
        before { params['hello'] = 'world' }

        it { expect(request.status).to eq 200 }
      end
    end

    context 'when endpoint have params validation' do
      let(:request_path) { '/validated' }
      let(:params) { {"dogs" => ['Lobelia']} }

      context 'and the given Definition is wrongly use the :of expression' do
        it 'should raise error telling how wrong move that was' do
          expect do
            rack_app do
              validate_params { required 'dogs', :class => Integer, :of => String }
              get('/test') { 'OK' }
            end
          end.to raise_error('Integer class must implement #each method to use :of expression in parameter definition')
        end
      end

      context 'and a get parameter is an array with brackets notation' do
        context 'and contains one value' do
          let(:params) { {'dogs[]' => ['Molly']} }

          it { expect(request.status).to eq 200 }
          it { expect(request.body).to eq 'OK' }
        end

        context 'and contains more value' do
          let(:params) { {'dogs' => ['Molly', 'Sunny']} }

          it { expect(request.status).to eq 200 }
          it { expect(request.body).to eq 'OK' }
        end
      end

      context 'and required param is in the right format' do
        before { params['dogs'] = ['Lobelia'] }
        it { expect(request.status).to eq 200 }
        it { expect(request.body).to eq 'OK' }
      end

      context 'and at least one required class missing' do
        before { params.delete('dogs') }
        it { expect(request.status).to eq 422 }
        it { expect(request.body).to eq "422 Unprocessable Entity\nmissing key: dogs(Array)" }
      end

      context 'and with invalid format' do
        before { params['numbers'] = 'hello' }
        it { expect(request.status).to eq 422 }
        it { expect(request.body).to match /invalid type for numbers: Array of Integer expected/ }
      end

      context 'when undefined parameter given' do
        before { params['is_admin'] = true }

        it { expect(request.status).to eq 422 }
        it { expect(request.body).to match /invalid key: is_admin/ }
      end

      context 'when required fields are all right' do
        before { params['dogs'] = ['Torka'] }

        context 'and any of the optional parameter is missing' do
          before { params.delete('numbers') }
          it { expect(request.status).to eq 200 }
          it { expect(request.body).to eq 'OK' }
        end

        context 'and one of the optional parameter are given' do
          context 'and in a valid form' do
            before { params['numbers'] = %w(1 2 3) }
            it { expect(request.status).to eq 200 }
            it { expect(request.body).to eq 'OK' }
          end

          context 'and with an invalid array type' do
            before { params['numbers'] = %w(a b c) }
            it { expect(request.status).to eq 422 }
            it { expect(request.body).to match /invalid type for numbers: Array of Integer expected/ }
          end

          context 'and with an valid complex class like Numeric' do
            before { params['numeric'] = '11.5' }
            it { expect(request.status).to eq 200 }
            it { expect(request.body).to match 'OK' }
          end
        end
      end
    end
  end

  describe '#validated_params' do
    rack_app do
      desc 'validated endpoint for env setting testing'
      validate_params do
        required 'a',  :type => Numeric
        required 'b',  :type => DateTime
        optional 'c0',  :type => Array, :of => Float
        optional 'c1',  :type => Array, :of => Float
        optional 'c2',  :type => Array, :of => Float
        optional 'c3',  :type => Array, :of => Float
        optional 'd',  :type => :boolean
        optional 'e',  :type => Integer
        optional 'f',  :type => Float
        required 'id', :type => Integer
      end
      get '/validated_params/:id' do
        Marshal.dump(validated_params)
      end

      desc 'unvalidated endpoint for validated_params checking from env'
      get '/unvalidated_params' do
        Marshal.dump(validated_params)
      end
    end

    let(:request) { get(:url => request_path, :params => params) }
    subject { Marshal.load(request.body) }

    context 'when endpoint called with no validate_params definition' do
      let(:request_path) { '/unvalidated_params' }

      it { is_expected.to be nil }
    end

    context 'when endpoint called with validate_params definition' do
      let(:request_path) { '/validated_params/' + id }
      let(:id) { '123' }

      before do
        params['a'] = '123.45'
        params['b'] = '2016-07-25T20:35:35+02:00'
        params['c0'] = [1.5]
        params['c1'] = [1.5, 2.3]
        params['c2'] = [3.14]
        params['c3'] = [3.14, 42.0]
        params['d'] = true
        params['e'] = 123
        params['f'] = 456.789
      end

      it { is_expected.to be_a Hash }
      it { expect(subject['a']).to eq 123.45 }
      it { expect(subject['b']).to eq DateTime.parse(params['b']) }
      it { expect(subject['c0']).to eq params['c0'] }
      it { expect(subject['c1']).to eq params['c1'] }
      it { expect(subject['c2']).to eq params['c2'] }
      it { expect(subject['c3']).to eq params['c3'] }
      it { expect(subject['d']).to eq params['d'] }
      it { expect(subject['e']).to eq params['e'] }
      it { expect(subject['f']).to eq params['f'] }
      it { expect(subject['id']).to eq 123 }
    end
  end

  describe '.router.endpoints' do
    rack_app do
      desc 'validated endpoint with params'
      validate_params do
        required 'dogs', :class => Array, :of => String, :desc => 'dog names', :example => ['pug']
        optional 'numbers', :class => Array, :of => Integer, :desc => 'some number'
        optional :number, :class => Integer, :description => 'one number alone'
        optional 'numeric', :class => Numeric
      end
      get '/path' do
        'OK'
      end
    end

    it 'router endpoint paths should have information about validated_params' do
      endpoint = rack_app.router.endpoints.first

      expected_description = {
        :required => {
          'dogs' => {
            :class => Array, :of => String,
            :example => ['pug'], :description => 'dog names'
          }
        },
        :optional => {
          'numbers' => {
            :class => Array, :of => Integer,
            :example => nil, :description => 'some number'
          },
          'number' => {
            :class => Integer, :of => nil,
            :example => nil, :description => 'one number alone'
          },
          'numeric' => {
            :class => Numeric, :of => nil,
            :example => nil, :description => nil
          }
        }
      }

      expect(endpoint.properties[:route][:params]).to eq expected_description
    end
  end
end
