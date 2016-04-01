require 'rack/app'
require 'optparse'
class Rack::App::CLI

  require 'rack/app/cli/command'

  def self.start(argv)
    @argv = Rack::App::Utils.deep_dup(argv)

    context = {}
    Kernel.__send__(:define_method, :run) { |app, *_| context[:app]= app }
    config_ru_file_path = Rack::App::Utils.pwd('config.ru')
    load(config_ru_file_path) if File.exist?(config_ru_file_path)

    context[:app].cli.start(argv)
  end

  def start(argv)
    command_name = argv.shift
    command = find_command_for(command_name)
    command && command.start(argv)
  end

  protected

  def find_command_for(command_name)
    commands.find { |command| command.name == command_name }
  end

  def merge!(cli)
    commands.push(*cli.commands)
    self
  end

  def commands
    @commands ||= []
  end

  def command(name, &block)
    command_prototype = Rack::App::Utils.deep_dup(Rack::App::CLI::Command)
    command_prototype.instance_exec(&block)
    commands << command_prototype.new(name)
  end

end