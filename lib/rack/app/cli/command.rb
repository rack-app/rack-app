class Rack::App::CLI::Command

  require 'optparse'

  class << self

    def options_parser_options
      @options_parser_options ||= []
    end

    def description(message = nil)
      @description = message unless message.nil?
      @description || ''
    end

    alias desc description

    def option(*args, &block)
      options_parser_options << {:args => args, :block => block}
    end

    alias on option

    def action(&block)
      @action = block unless block.nil?
      @action || Proc.new {}
    end

  end

  attr_reader :name

  def initialize(name)
    @name = name.to_s
    @option_parser = OptionParser.new
    self.class.options_parser_options.each { |h| @option_parser.on(*h[:args], &h[:block]) }
  end

  def description
    self.class.description
  end

  def start(argv)
    @option_parser.parse!(argv)
    instance_exec(*argv,&(self.class.action))
  end

end