require 'spec_helper'

describe Rack::App::Utils do

  let(:instance) { Object.new.tap { |o| o.extend(described_class) } }

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
    let(:path_parts){[]}
    subject { instance.pwd(*path_parts) }

    context 'when rails is not present' do

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
    subject{ instance.uuid }

    it { is_expected.to match /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/ }

    it { is_expected.to_not eq instance.uuid }

  end

end