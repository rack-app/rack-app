class Rack::App::Middlewares::MethodOverride

  ALLOWED_METHODS = %w[GET POST].freeze
  METHOD_OVERRIDE_PARAM_KEY = "_method".freeze
  HTTP_METHOD_OVERRIDE_HEADER = "HTTP_X_HTTP_METHOD_OVERRIDE".freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    if affected_request?(env)
      try_override(env)
    end

    @app.call(env)
  end

  protected

  def try_override(env)
    method = method_override(env)
    if valid_https_method?(method)
      set_request_method(method, env)
    end
  end

  def set_request_method(method, env)
    env[Rack::App::Constants::ENV::METHODOVERRIDE_ORIGINAL_METHOD] = env[Rack::REQUEST_METHOD]
    env[Rack::REQUEST_METHOD] = method
  end

  def valid_https_method?(method)
    Rack::App::Constants::HTTP::METHODS.include?(method)
  end

  def affected_request?(env)
    ALLOWED_METHODS.include?(env[Rack::REQUEST_METHOD])
  end

  def method_override(env)
    req = Rack::Request.new(env)
    method = env[HTTP_METHOD_OVERRIDE_HEADER] ||
              method_override_param(req,:POST) ||
                method_override_param(req,:GET)

    method.to_s.upcase
  end

  def method_override_param(req, http_method)
    req.__send__(http_method)[METHOD_OVERRIDE_PARAM_KEY]
  rescue Rack::Utils::InvalidParameterError, Rack::Utils::ParameterTypeError
  end

end
