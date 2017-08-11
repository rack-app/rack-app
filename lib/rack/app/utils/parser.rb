require 'time'
module Rack::App::Utils::Parser
  extend(self)

  require 'rack/app/utils/parser/custom'
  require 'rack/app/utils/parser/string'
  require 'rack/app/utils/parser/boolean'
  require 'rack/app/utils/parser/float'
  require 'rack/app/utils/parser/integer'
  require 'rack/app/utils/parser/numeric'

  def parse(type, str)
    string = str.to_s
    parser = get_parser(type)
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
    when type == :date
      self::Custom.new(::Date)
    when type == :time
      self::Custom.new(::Time)
    when [:date_time, :datetime].include?(type)
      self::Custom.new(::DateTime)
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
