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

  define :puts_output do |expected_message|
    supports_block_expectations

    match do |example|
      expect(STDOUT).to receive(:puts).with(expected_message)
      example.call
      true
    end
  end

  describe '#start' do
    subject(:after_run) { command.start(argv) }

    context 'given that endpoints defined in the application' do
      rack_app do
        desc 'example description'
        get '/a/:b/c' do
        end
      end

      it { expect{ after_run }.to puts_output "GET   /a/:b/c   example description" }

      context 'when verbose flag given' do
        let(:argv) { ["--verbose"] }

        let(:expected_definition_path) do
            endpoint = rack_app.router.endpoints.first
            endpoint.properties[:callable].source_location.join(":")
        end

        it { expect{ after_run }.to puts_output "GET   /a/:b/c   example description   #{expected_definition_path}" }
      end
    end
  end
end
