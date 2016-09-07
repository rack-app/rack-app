class Rack::App::Serializer

  attr_reader :logic

  def initialize(&block)
    @logic = block || lambda { |o| o.to_s }
  end

  def serialize(object)
    String(@logic.call(object))
  end

end
