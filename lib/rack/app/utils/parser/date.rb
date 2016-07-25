require 'date'
class Rack::App::Utils::Parser::Date
  def parse(str)
    ::Date.parse(str)
  end

  def validate(str)
    [
      /^\d+-\d\d-\d\d$/,
      /^\w+, \d+ \w+ \d+$/
    ].any? do |regexp|
      !!(str =~ regexp)
    end
  end
end
