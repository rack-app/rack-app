require "enumerator"
class Rack::App::RequestStream
  include Enumerable

  def initialize(io, parser)
    @io = io
    @parser = parser
  end

  def each(&block)
    enum = Enumerator.new do |y|
      # @io.rewind
      while chunk = @io.gets
        y << @parser.call(chunk)
      end
    end

    block_given? ? enum.each(&block) : enum
  end
end
