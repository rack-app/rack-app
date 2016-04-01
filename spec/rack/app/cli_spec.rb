require 'spec_helper'
describe Rack::App::CLI do

  let(:gem_file_path){ File.join(File.dirname(__FILE__), 'cli_spec', 'Gemfile')}
  before { allow(ENV).to receive(:[]).with('BUNDLE_GEMFILE').and_return(gem_file_path) }

  describe '.start' do
    subject { described_class.start(argv) }

    context 'when cli is defined in the main application' do
      let(:argv) { %W[ test test_content -c hello  ] }

      it { expect(subject).to eq ['test_content', 'hello'] }
    end

    context 'when cli is defined in a mounted application' do
      let(:argv) { %W[ hello this ] }

      it { expect(subject).to eq 'hello this!' }
    end

  end

end