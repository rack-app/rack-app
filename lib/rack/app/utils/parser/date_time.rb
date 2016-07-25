require 'date'
class Rack::App::Utils::Parser::DateTime
  def parse(str)
    ::DateTime.parse(str)
  end

  def validate(str)
    [
      /(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})[+-](\d{2})\:(\d{2})/,
      /^\w+, \d+ \w+ \d+ \d\d:\d\d:\d\d \+\d+$/,
      /^-?\d+-\d\d-\d\d\w\d\d:\d\d:\d\d\+\d\d:\d\d$/,
      /\w+ \w+ \d+ \d+ \d+:\d+:\d+ \w+\+\d+ \(\w+\)/,
      /^-?\d+-\d\d?-\d\d?\w\d\d?:\d\d?:\d\d?\w$/
    ].any? do |regexp|
      !!(str =~ regexp)
    end
  end
end
