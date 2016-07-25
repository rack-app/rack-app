class Rack::App::Utils::Parser::Numeric
  def parse(str)
    case true
    when int_parser.validate(str)
      int_parser.parse(str)
    when float_parser.validate(str)
      float_parser.parse(str)
    else
      str
    end
  end

  def validate(str)
    int_parser.validate(str) || float_parser.validate(str)
  end

  protected

  def int_parser
    Rack::App::Utils::Parser::Integer.new
  end

  def float_parser
    Rack::App::Utils::Parser::Float.new
  end
end
