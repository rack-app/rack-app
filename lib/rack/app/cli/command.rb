class Rack::App::CLI::Command

  require 'optparse'

  class << self

    def optparse_options
      @options_parser_options ||= []
    end

    def description(message = nil)
      @description = message unless message.nil?
      @description || ''
    end

    alias desc description

    def option(*args, &block)
      optparse_options << {:args => args, :block => block}
    end

    alias on option

    def action(&block)
      define_method(:action, &block)
    end

  end

  attr_reader :name

  def initialize(name)
    @name = name.to_s
    @option_parser = OptionParser.new
    attach_definitions!
    update_banner!
  end

  def help_message
    @option_parser.help
  end

  def description
    self.class.description
  end

  def start(argv)
    @option_parser.parse!(argv)
    action(*argv)
  rescue ArgumentError => ex
    $stderr.puts(ex.message)
  end

  def action(*argv)
  end

  protected

  def attach_definitions!
    self.class.optparse_options.each do |h|
      @option_parser.on(*h[:args]) do |*args|
        instance_exec(*args,&h[:block])
      end
    end
  end

  def update_banner!

    banner = @option_parser.banner
    banner.sub!('[options]', "#{@name} [options]")

    # [[:req, :a], [:opt, :b], [:rest, :c], [:keyreq, :d], [:keyrest, :e]]
    (method(:action).parameters rescue []).each do |type, keyword|
      case type
        when :req
          banner.concat(" <#{keyword}>")

        when :opt
          banner.concat(" [<#{keyword}>]")

        when :rest, :keyrest
          banner.concat(" [<#{keyword}> <#{keyword}> ...]")

      end
    end

    banner.concat("\n\n")
    banner.concat(description)
    banner.concat("\n\n")

  end

end