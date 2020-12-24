require 'spec_helper'

describe Rack::App::FileServer do
  let(:instance) { described_class.new(root_folder) }
  let(:root_folder) { Rack::App::Utils.pwd('spec', 'fixtures') }
  let(:request_method) { 'GET' }

  let(:env) do
    {
        ::Rack::App::Constants::ENV::PATH_INFO => path_info,
        ::Rack::App::Constants::ENV::REQUEST_METHOD => request_method
    }
  end

  describe '#call' do
    subject { instance.call(env) }

    context 'when namespace not defined it should use "/" as default' do
      let(:namespace) { nil }

      context 'and requested file exist' do
        let(:path_info) { '/raw.txt' }

        it 'should answer with status 200' do
          expect(subject[0]).to eq 200
        end

        it 'should set the response headers' do
          expect(subject[1].keys).to match_array ['Last-Modified', 'Content-Type', 'Content-Length']
        end

        it 'should response with a ::Rack::File instance' do
          expect(subject[2]).to respond_to :each
        end

        it 'should include the file content' do
          file_content = []
          subject[2].each { |line| file_content << line }
          expect(file_content.join).to eq "hello world!\nhow you doing?"
        end

      end

      context 'and requested file exist' do
        let(:path_info) { '/invalid.txt' }

        it 'should answer with status 200' do
          expect(subject[0]).to eq 404
        end

        it 'should include the file content' do
          expect(subject[2].join).to eq "File not found: /invalid.txt\n"
        end

      end

    end

    context 'when namespace set to "/"' do
      let(:namespace) { '/' }

      context 'and requested file exist' do
        let(:path_info) { '/raw.txt' }

        it 'should answer with status 200' do
          expect(subject[0]).to eq 200
        end

        it 'should set the response headers' do
          expect(subject[1].keys).to match_array ['Last-Modified', 'Content-Type', 'Content-Length']
        end

        it 'should response with a ::Rack::File instance' do
          expect(subject[2]).to respond_to :each
        end

        it 'should include the file content' do
          file_content = []
          subject[2].each { |line| file_content << line }
          expect(file_content.join).to eq "hello world!\nhow you doing?"
        end

      end

      context 'and requested file exist' do
        let(:path_info) { '/invalid.txt' }

        it 'should answer with status 200' do
          expect(subject[0]).to eq 404
        end

        it 'should include the file content' do
          expect(subject[2].join).to eq "File not found: /invalid.txt\n"
        end

      end

    end

    context 'when namespace set to an alternative path such as "/something"' do
      let(:namespace) { '/something' }

      context 'and requested file exist' do
        let(:path_info) { '/something/raw.txt' }

        it 'should answer with status 200' do
          expect(subject[0]).to eq 200
        end

        it 'should set the response headers' do
          expect(subject[1].keys).to match_array ['Last-Modified', 'Content-Type', 'Content-Length']
        end

        it 'should response with a ::Rack::File instance' do
          expect(subject[2]).to respond_to :each
        end

        it 'should include the file content' do
          file_content = []
          subject[2].each { |line| file_content << line }
          expect(file_content.join).to eq "hello world!\nhow you doing?"
        end

      end

      context 'and requested file not exist' do
        let(:path_info) { '/something/invalid.txt' }

        it 'should answer with status 404' do
          expect(subject[0]).to eq 404
        end

        it 'should include the file content' do
          expect(subject[2].join).to match /File not found/
        end

      end

    end

  end

  describe '#serve_file' do
    subject do
      described_class.serve_file({}, path)
    end

    fixture_path = Rack::App::Utils.pwd('spec/fixtures/raw.txt')

    it_should_serve_the_file = lambda do |spec|
      spec.it 'should serve file' do
        rack_resp = subject
        expect(rack_resp[0]).to eq 200
        expect(rack_resp[1].keys).to match_array(['Last-Modified', 'Content-Type', 'Content-Length'])
        expect(rack_resp[2]).to respond_to :each
      end
    end

    context 'when file served from a project directory where everything belongs to the running process' do
      let :path do
        fixture_path
      end

      it_should_serve_the_file.call(self)
    end

    context 'when file served from a directory where not all file is accessible' do
      let :path do
        @tmpdir_path = Dir.mktmpdir('rack-app-serve-file-tests-')
        forbidden_file_path = File.join(@tmpdir_path, 'forbidden.txt')
        File.open(forbidden_file_path, 'w') { |f| f.write('foo bar baz') }
        File.chmod(0, forbidden_file_path)
        file_to_serve = File.join(@tmpdir_path, 'raw.txt')
        FileUtils.copy_file(fixture_path, file_to_serve)
        file_to_serve
      end

      after :each do
        FileUtils.rm_rf(@tmpdir_path) if @tmpdir_path
      end

      it_should_serve_the_file.call(self)
    end

    context 'when file served from a directory where multiple user has files with not permiting file mod' do
      # this is a terrible test,
      # I can't create a real life use-case
      # where there is a multi-user shared directory
      # with the test runner user.
      # Since OS behaviour is considered non-volatile,
      # I stub glob out to mimic failing with EPERM error.
      # it is far from a proper test, and not likely to help me in the future.
      before do
        # glob should not even happen
        allow(Dir).to(receive(:glob)) { |*args| raise Errno::EPERM }
      end

      let :path do
        @tmpdir_path = Dir.mktmpdir('rack-app-serve-file-tests-')
        forbidden_file_path = File.join(@tmpdir_path, 'forbidden.txt')
        File.open(forbidden_file_path, 'w') { |f| f.write('foo bar baz') }
        File.chmod(0, forbidden_file_path)
        file_to_serve = File.join(@tmpdir_path, 'raw.txt')
        FileUtils.copy_file(fixture_path, file_to_serve)
        file_to_serve
      end

      after :each do
        FileUtils.rm_rf(@tmpdir_path) if @tmpdir_path
      end

      it_should_serve_the_file.call(self)
    end
  end

end
