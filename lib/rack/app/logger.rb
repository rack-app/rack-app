require 'logger'
class Rack::App::Logger < ::Logger
  attr_writer :id

  def initialize(*args)
    super
    configure!
  end

  protected

  def id
    @id ||= SecureRandom.hex
  end

  def configure!
    original_formatter = Logger::Formatter.new
    self.formatter = proc do |severity, datetime, progname, msg|
      fmsg = msg.is_a?(::Hash) ? (defined?(::JSON) ? JSON.dump(msg) : msg) : msg
      fprname = progname || id
      original_formatter.call(severity, datetime, fprname, fmsg)
    end
  end
end
