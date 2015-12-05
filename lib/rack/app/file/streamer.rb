class Rack::App::File::Streamer

  def each(&blk)
    @file.each(&blk)
  ensure
    @file.close
  end

  def to_a
    @file.to_a.map(&:chomp)
  end

  protected

  def initialize(path)
    @file = File.open(path)
  end

end