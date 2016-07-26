module Rack::App::Utils::Parser
  extend(self)

  require 'rack/app/utils/parser/custom'
  require 'rack/app/utils/parser/string'
  require 'rack/app/utils/parser/boolean'
  require 'rack/app/utils/parser/date'
  require 'rack/app/utils/parser/time'
  require 'rack/app/utils/parser/date_time'
  require 'rack/app/utils/parser/float'
  require 'rack/app/utils/parser/integer'
  require 'rack/app/utils/parser/numeric'

  def parse(type, str)
    string = str.to_s
    parser = get_parser(type)
    # puts "#{type} - #{str.inspect} - #{parser.inspect} - #{parser.validate(string)}"
    return unless parser.validate(string)
    parser.parse(string)
  end

  protected

  def get_parser(type)
    case true
    when [::String, :string].include?(type)
      self::String.new
    when [::TrueClass, ::FalseClass, :boolean].include?(type)
      self::Boolean.new
    when [::Date, :date].include?(type)
      self::Date.new
    when [::Time, :time].include?(type)
      self::Time.new
    when [::DateTime, :date_time, :datetime].include?(type)
      self::DateTime.new
    when [::Integer, :integer].include?(type)
      self::Integer.new
    when [::Float, :float].include?(type)
      self::Float.new
    when [::Numeric, :numeric].include?(type)
      self::Numeric.new
    else
      self::Custom.new(type)
    end
  end
end
