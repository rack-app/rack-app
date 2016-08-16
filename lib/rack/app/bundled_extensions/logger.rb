Rack::App::Extension.register(:logger) do

  require "logger"
  require "securerandom"

  logger_class = Class.new
  logger_class.class_eval do

    def initialize(request_id)
      @request_id = request_id
      @logger = ::Logger.new(STDOUT)
    end

    [:info, :warn, :error, :fatal, :unknown].each do |log_level|
      define_method(log_level) do |msg|
        if msg.is_a?(Hash)
          @logger.__send__(log_level, @request_id){format_hash(msg)}
        else
          @logger.__send__(log_level, @request_id){String(msg)}
        end
      end
    end

    protected

    begin
      require "json"
    rescue LoadError
    end

    def format_hash(hash)
      if defined?(::JSON)
        JSON.dump(hash)
      else
        hash.inspect
      end
    end

    def method_missing(name,*args)
      if @logger.respond_to?(:binding)
        @logger.__send__(name,*args)
      else
        super
      end
    end

  end

  define_method(:logger) do
    @logger ||= logger_class.new(request.env['HTTP_X_REQUEST_ID'] || SecureRandom.hex)
  end

end
