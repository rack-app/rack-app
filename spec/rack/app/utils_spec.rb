require 'spec_helper'

describe Rack::App::Utils do

  def new_subject
    Object.new.tap { |o| o.extend(described_class) }
  end

  describe '#normalize_path' do
    subject { new_subject.normalize_path(request_path) }

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

end