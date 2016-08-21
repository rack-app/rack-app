module Rack::App::Streamer::Scheduler::Null

  extend(self)

  def schedule(*)
     yield
   end

  def defer(*)
    yield
  end

end
