class Rack::App::Utils::Parser::Integer
  def parse(str)
    str.to_s.to_i
  end

  def validate(str)
    !!(str =~ /^\d+$/)
  end
end
