Rack::App::Extension.register(:logger) do

  require "logger"
  require "securerandom"

  define_method(:logger) do
    @logger ||= lambda do
      log = ::Logger.new(STDOUT)
      original_formatter = Logger::Formatter.new
      log.formatter = proc do |severity, datetime, progname, msg|
        fmsg = msg.is_a?(::Hash) ? (defined?(::JSON) ? JSON.dump(msg) : msg) : msg
        fprname = progname || request.env['HTTP_X_REQUEST_ID'] || SecureRandom.hex
        original_formatter.call(severity, datetime, fprname, fmsg)
      end
      return log
    end.call
  end

end
