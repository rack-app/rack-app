require 'spec_helper'
src_folder = Dir.pwd
describe Rack::App::CLI do

  let(:project_folder) { File.join(File.dirname(__FILE__), 'cli_spec') }

  let(:argv) { [] }

  before{ Rack::App::CLI::Fetcher.instance_variable_set(:@server_based_lookup, nil) }
  after{ Rack::App::CLI::Fetcher.instance_variable_set(:@server_based_lookup, nil) }

  describe '.start' do
    subject { described_class.start(argv) }

    context 'when cli ran outside from the project folder' do
      before{ Dir.chdir(src_folder) }

      it 'should write out default commands upon not finding any application class' do

        expect($stdout).to receive(:puts).with(
            [
                "Usage: rspec <command> [options] <args>\n\n",
                "Some useful rspec commands are:",
                "   commands  list all available command",
                "     routes  list all available endpoint"
            ].join("\n")
        )

        subject

      end

    end

    context 'when current folder is in a project root' do
      before { Dir.chdir(project_folder) }

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

      context 'when command list requested' do
        before { argv << 'commands' }

        it 'should return the command list' do
          expect($stdout).to receive(:puts).with(
              [
                  "Usage: rspec <command> [options] <args>\n\n",
                  "Some useful rspec commands are:",
                  "   commands  list all available command",
                  "     routes  list all available endpoint",
                  "      hello  hello world cli",
                  "       test  it's a sample test cli command"
              ].join("\n")
          )

          subject
        end

      end

      context 'when invalid command requested' do
        before { argv << 'invalid' }

        it 'should return the command list' do
          expect($stdout).to receive(:puts).with(
              [
                  "Usage: rspec <command> [options] <args>\n\n",
                  "Some useful rspec commands are:",
                  "   commands  list all available command",
                  "     routes  list all available endpoint",
                  "      hello  hello world cli",
                  "       test  it's a sample test cli command"
              ].join("\n")
          )

          subject
        end

      end

      context 'when help requested' do
        before { argv << 'help' }

        it 'should return the command list' do
          expect($stdout).to receive(:puts).with(
              [
                  "Usage: rspec <command> [options] <args>\n\n",
                  "Some useful rspec commands are:",
                  "   commands  list all available command",
                  "     routes  list all available endpoint",
                  "      hello  hello world cli",
                  "       test  it's a sample test cli command"
              ].join("\n")
          )

          subject
        end

        context 'and action defined as argument' do

          context 'such as test action' do
            before { argv << 'test' }

            it 'should return the command list' do
              expect($stdout).to receive(:puts).with(
                  [
                      "Usage: rspec test [options] <file_path>\n",
                      "it's a sample test cli command\n",
                      "    -c, --content [STRING]           add content to test file the following string\n"
                  ].join("\n")
              )

              subject
            end

          end

          context 'such as test action' do
            before { argv << 'hello' }

            it 'should return the command list' do
              expect($stdout).to receive(:puts).with(
                  [
                      "Usage: rspec hello [options] <word>\n",
                      "hello world cli\n\n"
                  ].join("\n")
              )

              subject
            end

          end

        end if RUBY_VERSION >= '1.9'

      end

      after { Dir.chdir(src_folder) }
    end

  end

end
