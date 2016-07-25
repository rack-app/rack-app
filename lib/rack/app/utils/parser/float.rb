class Rack::App::Utils::Parser::Float
  def parse(str)
    str.to_f
  end

  def validate(str)
    case str.to_s
      when /^\d+\.\d+$/, /^\d+,\d+$/
        return true
      else
        return false
    end
  end

end
