require 'time'
class Rack::App::Utils::Parser::Time
  def parse(str)
    ::Time.parse(str)
  end

  def validate(str)
    [
      /(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})[+-](\d{2})\:(\d{2})/,
      /^\d+-\d\d-\d\d \d\d:\d\d:\d\d \+\d+$/
    ].any? do |regexp|
      !!(str =~ regexp)
    end
  end
end
