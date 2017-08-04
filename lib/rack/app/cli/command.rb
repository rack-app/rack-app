class Rack::App::CLI::Command

  require 'optparse'
  require 'rack/app/cli/command/configurator'

  class << self

    def __option_definitions__
      @options_parser_options ||= []
    end

    def description(message = nil)
      @description = message unless message.nil?
      @description || ''
    end

    alias desc description

    def option(*args, &block)
      __option_definitions__ << {:args => args, :block => block}
    end

    alias on option

    def action(&block)
      define_method(:action, &block)
    end

  end

  def action(*argv)
    raise NotImplementedError
  end

  def start(argv)
    action(*argv)
  rescue ArgumentError => ex
    $stderr.puts(ex.message)
  end

end