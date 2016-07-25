class Rack::App::Utils::Parser::Boolean
  def parse(str)
    case true

    when true?(str)
      true

    when false?(str)
      false

    else
      str

    end
  end

  def validate(str)
    false?(str) || true?(str)
  end

  protected

  def false?(obj)
    !!(obj =~ /^false$/)
  end

  def true?(obj)
    !!(obj =~ /^true$/)
  end
end
