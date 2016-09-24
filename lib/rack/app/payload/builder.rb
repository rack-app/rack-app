class Rack::App::Payload::Builder

  def parser(&block)
    @parser_builder ||= Rack::App::Payload::Parser::Builder.new
    @parser_builder.instance_exec(&block) if block
    @parser_builder
  end

end
