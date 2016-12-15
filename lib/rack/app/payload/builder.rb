class Rack::App::Payload::Builder

  def parser_builder(&block)
    @parser_builder ||= Rack::App::Payload::Parser::Builder.new
    @parser_builder.instance_exec(&block) if block
    @parser_builder
  end

  alias parser parser_builder
  alias configure_parser parser_builder

end
