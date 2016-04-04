class Rack::App::Middlewares::HeaderSetter

  def initialize(app, headers)
    @app = app
    @headers = headers.freeze
  end

  def call(env)
    response = rack_response(@app.call(env))

    @headers.each do |header, value|
      response.headers[header] ||= value
    end

    set_content_type(response)

    response.finish
  end

  protected

  def set_content_type(response)
    return unless @headers[::Rack::CONTENT_TYPE]
    response.headers[::Rack::CONTENT_TYPE]= @headers[::Rack::CONTENT_TYPE]
  end

  def rack_response(raw_response)
    Rack::Response.new(raw_response[2], raw_response[0], raw_response[1])
  end

end