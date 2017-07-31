require 'irb'
require 'irb/completion'
class Rack::App::CLI::DefaultCommands::IRB < Rack::App::CLI::Command

  description 'open an irb session with the application loaded in'

  action do |*args|
    Rack::App::CLI.rack_app
    ARGV.clear
    ARGV.push(*args)
    ::IRB.start
  end

end