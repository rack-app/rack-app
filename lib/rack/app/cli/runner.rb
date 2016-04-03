class Rack::App::CLI::Runner

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
    command ? $stdout.puts(command.help_message) : show_commands
  end

  def start_command_for(command_name, argv)
    case command_name.to_s

      when 'commands'
        show_commands

      when 'help'
        show_help_message(argv)

    end

    command = command_for(command_name)

    command && command.start(argv)
  end

  def command_for(name)
    return if name.nil?

    commands[name.to_s.to_sym]
  end

  def commands
    @cli.commands
  end

end