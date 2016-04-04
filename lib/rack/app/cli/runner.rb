class Rack::App::CLI::Runner

  CommandNotFound = Class.new(StandardError)

  def initialize(app)
    @cli = app.respond_to?(:cli) ? app.cli : Rack::App::CLI.new
  end

  def start(argv)
    command_name = argv.shift
    start_command_for(command_name,argv)
  end

  protected

  def show_commands
    $stdout.puts(Rack::App::CLI::DefaultCommands::ListCommands.get_message(commands))
  end

  def show_help_message(argv)
    command_name = argv.shift
    command = command_for(command_name)
    options_parser = configure_command(command,command_name)

    $stdout.puts(options_parser.help)
  rescue CommandNotFound
    show_commands
  end

  def start_command_for(command_name, argv)
    case command_name.to_s

      when 'commands'
        return show_commands

      when 'help'
        return show_help_message(argv)

      else
        command = command_for(command_name)
        return run_command(argv, command, command_name)

    end
  end

  def run_command(argv, command, command_name)
    return if command.nil?

    option_parser = configure_command(command, command_name)
    option_parser.parse!(argv)
    command.start(argv)

  end

  def configure_command(command, command_name)
    option_parser = OptionParser.new
    Rack::App::CLI::Command::Configurator.configure(command, command_name, option_parser)
    return option_parser
  end

  def command_for(name)
    commands[(name || raise(CommandNotFound)).to_s.to_sym] || raise(CommandNotFound)
  end

  def commands
    @cli.commands
  end

end