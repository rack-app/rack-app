require 'spec_helper'

describe Rack::App::File::Parser do

  let(:controller_instance) { double('Rack::App/instance') }
  let(:instance) { described_class.new(controller_instance) }

  let(:file) { double('File/instance').as_null_object }
  let(:file_path) { 'sample/file/path' }
  before { allow(File).to receive(:open).with(file_path).and_return(file) }

  describe '#parse' do

    subject { instance.parse(file_path) }

    let(:file_path) { '/sample/file/path' }

    it { is_expected.to be_a Rack::App::File::Streamer }

    it 'should pass the file path to the streamer' do

      allow(file).to receive(:each) do |*args, &block|
        block.call("hello!\n")
      end

      block_called = false
      subject.each do |line|
        block_called ||= true
        expect(line).to eq "hello!\n"
      end

      expect(block_called).to be true

    end

  end

  describe '#file_type' do
    let(:extension) { ".#{Random.rand(0..10)}" }
    let(:file_path) { "file_name#{extension}" }
    subject { instance.file_type(file_path) }

    it { is_expected.to eq extension }
  end

  describe '.format_request_path' do
    let(:request_path) { '/sample/endpoint/path' }
    subject { described_class.format_request_path(request_path) }

    it { is_expected.to be request_path }
  end

end