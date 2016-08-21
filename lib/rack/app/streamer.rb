# Copyright (c) 2007, 2008, 2009 Blake Mizerany
# Copyright (c) 2010, 2011, 2012, 2013, 2014, 2015, 2016 Konstantin Haase
#
# Class of the response body in case you use #stream.
#
# Three things really matter: The front and back block (back being the
# block generating content, front the one sending it to the client) and
# the scheduler, integrating with whatever concurrency feature the Rack
# handler is using.
#
# Scheduler has to respond to defer and schedule.
class Rack::App::Streamer
  require "rack/app/streamer/scheduler"

  def initialize(env, options={}, &back)
    @serializer = env[Rack::App::Constants::ENV::SERIALIZER]
    @scheduler = options[:scheduler] || Rack::App::Streamer::Scheduler.by_env(env)
    @keep_open = options[:keep_open] || false
    @back = back.to_proc
    @callbacks, @closed = [], false
  end

  def close
    return if closed?
    @closed = true
    @scheduler.schedule { @callbacks.each { |c| c.call }}
  end

  def each(&front)
    @front = front
    @scheduler.defer do
      begin
        @back.call(self)
      rescue Exception => ex
        @scheduler.schedule { raise(ex) }
      end
      close unless @keep_open
    end
  end

  def <<(data)
    @scheduler.schedule { @front.call(@serializer.serialize(data)) }
    self
  end

  def callback(&block)
    return yield if closed?
    @callbacks << block
  end

  alias errback callback

  def closed?
    @closed
  end
end
