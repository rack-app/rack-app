require 'spec_helper'

describe Rack::App::File::Streamer do

  let(:file_path) { Rack::App::Utils.pwd('spec', 'fixtures', 'raw.txt') }
  let(:instance) { described_class.new(file_path) }

  describe '#each' do
    subject { instance.take(2) }

    it 'should iterate over the file content' do
      is_expected.to eq ["hello world!\n", 'how you doing?']
    end

    it 'should ensure to run file.close always' do
      expect { instance.each.map { |l|} }.to raise_error(IOError, 'closed stream')
    end

  end

  describe '#render' do
    subject { instance.render(nil) }

    it { is_expected.to eq "hello world!\nhow you doing?" }
  end

  describe '#to_a' do
    subject { instance.to_a }

    it { is_expected.to eq ["hello world!\n", 'how you doing?'] }
  end

  describe '#mtime' do
    subject { instance.mtime }

    it { is_expected.to be_a String }

    it { is_expected.to match /(((Mon)|(Tue)|(Wed)|(Thu)|(Fri)|(Sat)|(Sun))[,]\s\d{2}\s(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s\d{4}\s(0\d|1\d|2[0-3])(\:)(0\d|1\d|2\d|3\d|4\d|5\d)(\:)(0\d|1\d|2\d|3\d|4\d|5\d)\s(GMT))/ }

  end

  describe '#length' do
    subject { instance.length }

    it { is_expected.to eq 27 }
  end

end
