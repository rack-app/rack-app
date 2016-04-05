module Rack::App::CLI::DefaultCommands::ListCommands

  extend self

  PRESERVED_KEYWORDS = ['commands', 'help', 'routes']

  def get_message(known_commands)
    puts_collection = []

    add_header(puts_collection)

    list_command_name = 'commands'
    rjust = known_commands.keys.push(*PRESERVED_KEYWORDS).map(&:to_s).map(&:length).max + 3

    puts_collection << [list_command_name.to_s.rjust(rjust), 'list all available command'].join('  ')
    puts_collection << ['routes'.to_s.rjust(rjust), 'list all available endpoint'].join('  ')

    known_commands.sort_by { |name, _| name.to_s }.each do |name, command|
      puts_collection << [name.to_s.rjust(rjust), command.class.description].join('  ')
    end

    puts_collection.join("\n")
  end

  protected

  def add_header(puts_collection)
    cmd_file_name = File.basename($0)
    puts_collection << "Usage: #{cmd_file_name} <command> [options] <args>\n\n"
    puts_collection << "Some useful #{cmd_file_name} commands are:"
  end

end