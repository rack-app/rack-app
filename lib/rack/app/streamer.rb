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
  def self.schedule(*) yield end
  def self.defer(*)    yield end

  def initialize(scheduler = self.class, keep_open = false, &back)
    @back, @scheduler, @keep_open = back.to_proc, scheduler, keep_open
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
      rescue Exception => e
        @scheduler.schedule { raise e }
      end
      close unless @keep_open
    end
  end

  def <<(data)
    @scheduler.schedule { @front.call(data.to_s) }
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
