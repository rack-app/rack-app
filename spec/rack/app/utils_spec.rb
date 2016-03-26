require 'spec_helper'
require File.join(File.dirname(__FILE__), 'utils_spec_helper.rb')
describe Rack::App::Utils do

  let(:instance) { Object.new.tap { |o| o.extend(described_class) } }

  describe '#deep_dup' do

    subject { instance.deep_dup(rack_app) }

    require 'rack/app/test'
    include Rack::App::Test

    rack_app do

      def self.test
        @test ||= {}
      end

      test[:hy]= 'no'

      get '/' do
        self.class
      end

    end

    it { expect(subject.object_id).to_not eq rack_app.object_id }

    it { expect(subject.test[:hy].object_id).to_not eq rack_app.test[:hy].object_id }

  end

  describe '#normalize_path' do
    subject { instance.normalize_path(request_path) }

    context 'when path is as how expected' do
      let(:request_path) { '/foo' }

      it { is_expected.to eq '/foo' }
    end

    context 'when per given even in the end' do
      let(:request_path) { '/baz/' }

      it { is_expected.to eq '/baz' }
    end

    context 'when no per given in the path' do
      let(:request_path) { 'bar' }

      it { is_expected.to eq '/bar' }
    end

    context 'when empty string given' do
      let(:request_path) { '' }

      it { is_expected.to eq '/' }
    end

  end


  describe '#pwd' do
    let(:path_parts) { [] }
    subject { instance.pwd(*path_parts) }

    context 'when gemfile path is present' do

      context 'and bundler already set the env file with the gem file path' do
        before { allow(ENV).to receive(:[]).with('BUNDLE_GEMFILE').and_return('/path/to/folder/Gemfile') }

        it { is_expected.to eq '/path/to/folder' }
      end

      context 'when bundler is not used and there is no env variable' do
        before { allow(ENV).to receive(:[]).with('BUNDLE_GEMFILE').and_return(nil) }

        it { is_expected.to eq Dir.pwd }
      end

    end

    context 'when array of path part is given' do
      let(:path_parts) { %w(hello world) }

      it { is_expected.to eq File.join(Dir.pwd, 'hello', 'world') }
    end

    context 'when string path given' do
      let(:path_parts) { '/hello/world' }

      it { is_expected.to eq File.join(Dir.pwd, 'hello', 'world') }
    end

  end

  describe '#uuid' do
    subject { instance.uuid }

    it { is_expected.to match /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/ }

    it { is_expected.to_not eq instance.uuid }

  end

  describe '#expand_path' do
    subject { UtilsSpecHelper.expand_path(file_path) }

    context 'when "app_scope_relative_path" given which includes the current application file name based folder path' do
      let(:file_path) { 'app_scope_relative' }

      it { is_expected.to eq Rack::App::Utils.pwd('spec', 'rack', 'app', 'utils_spec', 'app_scope_relative') }
    end

    context 'when "relative_path" given from the app location' do
      let(:file_path) { './relative' }

      it { is_expected.to eq Rack::App::Utils.pwd('spec', 'rack', 'app', 'relative') }
    end

    context 'when "absolute_path" given which means root folder as project folder' do
      let(:file_path) { '/spec/fixtures/raw.txt' }

      it { is_expected.to eq Rack::App::Utils.pwd('spec', 'fixtures', 'raw.txt') }
    end

    context 'when "absolute_path" given which meant from the system root' do
      let(:file_path) { Rack::App::Utils.pwd('absolute_path') }

      it { is_expected.to eq Rack::App::Utils.pwd('absolute_path') }
    end

  end

  describe '#namespace_folder' do
    subject { instance.namespace_folder(file_path_info) }
    let(:file_path_info) { "/rack-app/front_end/spec/rack/app/front_end_spec/layout.html.erb:2:in `block in singleton class'" }

    it { is_expected.to eq "/rack-app/front_end/spec/rack/app/front_end_spec/layout" }
  end

end