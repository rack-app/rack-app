class Rack::App::File::Streamer

  include Enumerable

  def each(&blk)
    @file.each(&blk)
  ensure
    @file.close
  end

  def to_a
    @file.to_a.map(&:chomp)
  end

  def render(object=nil)
    return self
  end

  protected

  def initialize(path)
    @file = File.open(path)
  end

end