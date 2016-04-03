require 'rack/app'
require 'optparse'
class Rack::App::CLI

  require 'rack/app/cli/command'
  require 'rack/app/cli/default_commands'
  require 'rack/app/cli/runner'

  class << self

    def start(argv)
      runner.start(argv)
    end

    def runner
      Rack::App::CLI::Runner.new(rack_app)
    end

    def rack_app
      @rack_app ||= lambda {
        context = {}
        Kernel.__send__(:define_method, :run) { |app, *_| context[:app]= app }
        config_ru_file_path = Rack::App::Utils.pwd('config.ru')
        load(config_ru_file_path) if File.exist?(config_ru_file_path)
        context[:app]
      }.call
    end

  end

  def merge!(cli)
    commands.merge!(cli.commands)
    self
  end

  def commands
    @commands ||= {}
  end

  protected

  def command(name, &block)
    command_prototype = Class.new(Rack::App::CLI::Command)
    command_prototype.class_exec(&block)
    commands[name.to_s.to_sym]= command_prototype.new(name.to_s.to_sym)
  end

end