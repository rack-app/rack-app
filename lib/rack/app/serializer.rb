class Rack::App::Serializer

  attr_reader :logic

  def initialize
    @logic = lambda { |o| o.to_s }
  end

  def set_serialization_logic(proc)
    @logic = proc
  end

  def serialize(object)
    @logic.call(object)
  end

end
