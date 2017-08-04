module Rack::App::CLI::Command::Configurator

  extend self

  def configure(command, name, options_parser)
    attach_definitions(command, options_parser, command.class.__option_definitions__)
    update_banner(command, name, options_parser.banner)
  end

  protected

  def attach_definitions(command, optparse, option_definitions)
    option_definitions.each do |h|
      optparse.on(*h[:args]) do |*args|
        command.instance_exec(*args, &h[:block])
      end
    end
  end

  def update_banner(command, name, banner)

    banner.sub!('[options]', "#{name} [options]")

    # [[:req, :a], [:opt, :b], [:rest, :c], [:keyreq, :d], [:keyrest, :e]]
    (command.method(:action).parameters rescue []).each do |type, keyword|
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
    banner.concat(command.class.description)
    banner.concat("\n\n")

  end

end