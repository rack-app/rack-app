module Rack::App::CLI::DefaultCommands::ListCommands
  extend self

  PRESERVED_KEYWORDS = %w[help routes irb].freeze

  DEFAULT_COMMANDS = {
    'routes' => Rack::App::CLI::DefaultCommands::ShowRoutes.description,
    'help' => 'list all available command or describe a specific command',
    'irb' => Rack::App::CLI::DefaultCommands::IRB.description
  }.freeze

  class Formatter
    def initialize(known_commands)
      @rjust = known_commands.keys.push(*PRESERVED_KEYWORDS).map(&:to_s).map(&:length).max + 3
    end

    def command_suggestion_line_by(name, desc)
      [name.to_s.rjust(@rjust), desc].join('  ')
    end

    def format(collection_hash)
      collection_hash.to_a.sort_by{ |k, v| k.to_s }.map do |name, desc|
        command_suggestion_line_by(name, desc)
      end.join("\n")
    end
  end

  def get_message(known_commands)
    collection = {}
    add_default_suggestions(collection)
    add_user_defined_commands(known_commands, collection)

    [
      header,
      Formatter.new(known_commands).format(collection)
    ].join("\n")
  end

  protected

  def header
    cmd_file_name = File.basename($PROGRAM_NAME)
    [
      "Usage: #{cmd_file_name} <command> [options] <args>\n\n",
      "Some useful #{cmd_file_name} commands are:"
    ].join("\n")
  end

  def add_default_suggestions(collection)
    collection.merge!(DEFAULT_COMMANDS)
  end

  def add_user_defined_commands(known_commands, collection)
    known_commands.sort_by { |name, _| name.to_s }.each do |name, command|
      collection[name] = command.class.description
    end
  end
end
