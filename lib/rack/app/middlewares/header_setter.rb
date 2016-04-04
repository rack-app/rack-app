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

    protocol_headers.each do |header|
      response.headers[header]= @headers[header]
    end

    response.finish
  end

  protected

  def protocol_headers
    [::Rack::CONTENT_TYPE].select { |header| @headers[header] }
  end

  def rack_response(raw_response)
    Rack::Response.new(raw_response[2], raw_response[0], raw_response[1])
  end

end