require 'spec_helper'
RSpec.describe Rack::App::CLI::DefaultCommands::ShowRoutes, command: 'rack-app routes' do
  subject(:command) { described_class.new }
  let(:argv) { [] }
  let(:option_parser) { OptionParser.new }

  before do
    Rack::App::CLI::Command::Configurator.configure(command, 'routes', option_parser)

    option_parser.parse!(argv)
  end

  before do
    allow(Rack::App::CLI).to receive(:rack_app).and_return(rack_app)
  end

  define :output do |expectation|
    supports_block_expectations

    match do |example|
      messages = []
      allow(STDOUT).to receive(:puts) do |*msgs|
        messages.push(*msgs)
        nil
      end

      example.call

      expect(messages.join("\n")).to expectation
    end
  end

  describe '#start' do
    subject(:after_run) { command.start(argv) }

    context 'given that endpoints defined in the application' do
      rack_app do

        desc 'example description'
        get '/a/:b/c' do
        end

        mount RackBasedApplication
      end

      it { expect{ after_run }.to output include "ANY   /[Mounted Application]" }
      it { expect{ after_run }.to output include "GET   /a/:b/c                  example description" }

      context 'when verbose flag given' do
        let(:argv) { ["--verbose"] }

        let(:expected_definition_path) do
            endpoint = rack_app.router.endpoints.first
            endpoint.properties[:callable].source_location.join(":")
        end

        let(:mounted_app_expected_location) { RackBasedApplication.method(:call).source_location.join(':') }

        it { expect{ after_run }.to output include "ANY   /[Mounted Application]                         #{mounted_app_expected_location}" }
        it { expect{ after_run }.to output include "GET   /a/:b/c                  example description   #{expected_definition_path}" }
      end
    end
  end
end
