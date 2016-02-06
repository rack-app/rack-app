class Rack::App::Serializer

  def initialize
    @proc = lambda { |o| o.to_s }
  end

  def set_serialization_logic(proc)
    @proc = proc
  end

  def serialize(object)
    @proc.call(object)
  end

end
