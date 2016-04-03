require 'spec_helper'
describe Rack::App::CLI do

  let(:gem_file_path) { File.join(File.dirname(__FILE__), 'cli_spec', 'Gemfile') }
  before { allow(ENV).to receive(:[]).with('BUNDLE_GEMFILE').and_return(gem_file_path) }

  describe '.start' do
    subject { described_class.start(argv) }

    context 'when cli is defined in the main application' do
      let(:argv) { %W[ test test_content -c hello  ] }

      it 'should execute the defined action for the test command' do
        expect($stdout).to receive(:puts).with('test_content hello')

        subject
      end

    end

    context 'when cli is defined in a mounted application' do
      let(:argv) { %W[ hello this ] }

      it 'should execute the defined action for the hello command' do
        expect($stdout).to receive(:puts).with('hello this!')

        subject
      end

    end

  end

end