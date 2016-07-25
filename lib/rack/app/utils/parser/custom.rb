class Rack::App::Utils::Parser::Custom
  def initialize(type)
    @type = type
  end

  def parse(str)
    @type.parse(str)
  end

  def validate(str)
    parse(str)
    return true
  rescue Exception
    return false
  end
end
