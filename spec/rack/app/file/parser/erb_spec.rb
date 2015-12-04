require 'spec_helper'

describe Rack::App::File::Parser::ERB do

  let(:app) { double('app') }
  before { allow(app).to receive(:hello).and_return('world') }

  let(:instance) { described_class.new(app) }
  let(:erb_string) { '<%= 5 * 5 %>' }
  let(:file_path) { '/file/path.html.erb' }

  before { allow(File).to receive(:read).with(file_path).and_return(erb_string) }

  describe '#parse' do
    subject { instance.parse(file_path) }

    it { is_expected.to eq ['25'] }

    context 'when there is reference to the controller class' do
      let(:erb_string) { '<%= hello %>' }

      it { is_expected.to eq ['world'] }
    end

  end

  describe '#file_type' do
    subject { instance.file_type(file_path) }

    it { is_expected.to eq '.html' }
  end

  describe '.format_request_path' do
    subject { described_class.format_request_path(file_path) }

    it { is_expected.to eq '/file/path.html' }
  end


end