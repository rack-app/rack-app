class Rack::App::Middlewares::HeaderSetter

  def initialize(app, headers)
    @app = app
    @headers = headers.freeze
  end

  def call(env)
     status, headers, body = @app.call(env)

    @headers.each do |header, value|
      headers[header] ||= value
    end

    [status, headers, body]
  end

end
