require "yaml"
require "spec_helper"
require 'rack/app/test'
describe Rack::App do
  include Rack::App::Test

  describe '#request' do
    context 'params' do

      context 'merged' do

        rack_app

        let(:request) { Rack::Request.new(request_env) }

        describe '#params' do

          require 'yaml'

          rack_app do

            get '/params' do
              YAML.dump(request.params)
            end

            get '/users/:user_id' do
              YAML.dump(request.params)
            end

            get '/domain/:addr' do
              YAML.dump(request.params)
            end

          end

          let(:request) { { :url => '/params', :env => {} } }

          subject { YAML.load(get(request).body) }

          context 'when query string given in request env' do

            context 'with single value' do
              before { request[:params] = { 'a' => 2 } }

              it { is_expected.to eq({ "a" => "2" }) }
            end

            context 'with single value and brackets notation' do
              before { request[:params] = { 'a[]' => 2 } }

              it { is_expected.to eq({ "a" => ["2"] }) }
            end

            context 'with array value' do
              before { request[:env][::Rack::QUERY_STRING] = 'a[]=2&a[]=3' }

              it { is_expected.to eq({ "a" => ["2", "3"] }) }
            end

            context 'with hash value' do
              before { request[:env][::Rack::QUERY_STRING] = 'a[b]=1&a[c]=2' }

              it { is_expected.to eq({ "a" => { "b" => "1", "c" => "2" } }) }
            end

            context 'with multiple value' do
              before { request[:env][::Rack::QUERY_STRING] = 'a=2&a=3' }

              it { is_expected.to eq({ "a" => ["2", "3"] }) }
            end

            context 'when dynamic path given with restful param' do
              before { request[:url] = '/users/123' }

              it { is_expected.to eq({ "user_id" => '123' }) }

              context 'and the dynamic path part include dot' do
                before { request[:url] = '/domain/example.com' }

                context 'and that "extension" has no unserializer defined' do
                  it { is_expected.to eq({ "addr" => 'example.com' }) }
                end

                context 'and that "extension" has unserializer defined' do
                  it("is specified in the formats_spec") {}
                end
              end
            end

          end

          context 'when reuqest env do not include any query' do
            before { request[:env]['QUERY_STRING'] = '' }

            it { is_expected.to eq({}) }
          end

        end
      end

      context 'query' do
        rack_app do
          get '/query_string_params' do
            YAML.dump(request.query_string_params)
          end

          get '/:id/:test/query_string_params' do
            YAML.dump(request.query_string_params)
          end
        end

        let(:original_path) { '/123/321/query_string_params' }
        let(:path) { original_path }

        describe '#query_string_params' do
          subject { YAML.load(get(path).body) }

          context "when no query_string_params given in the url" do
            let(:path) { "/query_string_params" }

            it { is_expected.to eq Hash.new }

            context "but there are path segments params" do
              let(:path) { original_path }

              it { is_expected.to eq Hash.new }
            end
          end

          context 'when query string included in the path' do
            let(:path) { original_path + '?hello=world' }

            it { is_expected.to eq 'hello' => 'world' }

            context 'and the query string content has overleaping value to the path_segments' do
              let(:path) { original_path + '?id=1&test=2' }

              it { is_expected.to eq 'id' => '1', 'test' => '2' }
            end
          end
        end
      end

      context 'path segment' do
        rack_app do
          get '/path_segments_params' do
            YAML.dump(request.path_segments_params)
          end

          get '/:id/:test/path_segments_params' do
            YAML.dump(request.path_segments_params)
          end
        end

        let(:original_path) { '/123/321/path_segments_params' }
        let(:path) { original_path }

        describe '#path_segments_params' do
          subject { YAML.load(get(path).body) }

          it { is_expected.to eq 'id' => '123', 'test' => '321' }

          context "when no path_segments_params given in the url" do
            let(:path) { "/path_segments_params" }

            it { is_expected.to eq Hash.new }
          end

          context 'when query string included in the path' do
            let(:path) { original_path + '?hello=world' }

            it { is_expected.to eq 'id' => '123', 'test' => '321' }

            context 'and the query string content has overleaping value to the path_segments' do
              let(:path) { original_path + '?id=1&test=2' }

              it { is_expected.to eq 'id' => '123', 'test' => '321' }
            end
          end
        end
      end

      context 'validated params' do
        let(:params) { {} }

        rack_app do
          desc 'validated endpoint for env setting testing'
          validate_params do
            required 'a', :type => Numeric
            required 'b', :type => DateTime
            optional 'c0', :type => Array, :of => Float
            optional 'c1', :type => Array, :of => Float
            optional 'c2', :type => Array, :of => Float
            optional 'c3', :type => Array, :of => Float
            optional 'd', :type => :boolean
            optional 'e', :type => Integer
            optional 'f', :type => Float
            required 'id', :type => Integer
          end
          get '/validated_params/:id' do
            Marshal.dump(request.params)
          end

          desc 'unvalidated endpoint for validated_params checking from env'
          get '/unvalidated_params' do
            Marshal.dump(request.params)
          end
        end

        let(:request) { get(:url => request_path, :params => params) }
        subject { Marshal.load(request.body) }

        context 'when endpoint called with no validate_params definition' do
          let(:request_path) { '/unvalidated_params' }

          it { is_expected.to eq params }
        end

        context 'when endpoint called with validate_params definition' do
          let(:request_path) { '/validated_params/' + id }
          let(:id) { '123' }

          before do
            params['a'] = '123.45'
            params['b'] = '2016-07-25T20:35:35+02:00'
            params['c0'] = 1.5
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
          it { expect(subject['c0']).to eq [params['c0']] }
          it { expect(subject['c1']).to eq params['c1'] }
          it { expect(subject['c2']).to eq params['c2'] }
          it { expect(subject['c3']).to eq params['c3'] }
          it { expect(subject['d']).to eq params['d'] }
          it { expect(subject['e']).to eq params['e'] }
          it { expect(subject['f']).to eq params['f'] }
          it { expect(subject['id']).to eq 123 }
        end
      end

      context 'payload' do

        context "POST + Form url encoded payload" do

          rack_app do

            post '/' do
              response.status = 418
              YAML.dump(request.params)
            end

          end

          it 'form encoded value is ' do
            post "/", payload: "foo=bar",
                 headers: { "Content-Type" => "application/x-www-form-urlencoded" }

            expect(last_response.status).to eq 418
            expect(YAML.load(last_response.body)).to eq({"foo" => "bar"})
          end

        end

      end
    end
  end
end
