module Rack::App::Streamer::Scheduler
  require "rack/app/streamer/scheduler/null"

  extend(self)

  def by_env(env)
    if env['async.callback'] && defined?(::EventMachine)
      ::EventMachine
    else
      ::Rack::App::Streamer::Scheduler::Null
    end
  end

end
