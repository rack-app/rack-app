Rack::App::Extension.register(:logger) do

  require "logger"
  require "securerandom"

  define_method(:logger) do
    @logger ||= Rack::App::Logger.new(STDOUT).tap do |this|
      this.id = request.env['HTTP_X_REQUEST_ID']
    end
  end

  before { logger }
  
end
