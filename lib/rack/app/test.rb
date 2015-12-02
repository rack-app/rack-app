require 'uri'
require 'rack/app'
module Rack::App::Test

  # magic ;)
  def self.included(klass)

    klass.define_singleton_method :rack_app do |rack_app_class=Rack::App, &constructor|

      subject_app = Class.new(rack_app_class)
      subject_app.instance_eval(&constructor)

      klass.__send__ :define_method, :rack_app do
        @rack_app = subject_app
      end

    end

  end

  [:get,:post,:put,:delete,:options].each do |request_method|
    define_method(request_method) do |url,properties={}|
      rack_app.call(request_env_by(request_method,url,properties)).last
    end

  end

  def format_properties(properties)
    raise('use hash format such as params: {"key" => "value"} or headers with the same concept') unless properties.is_a?(Hash)
    properties[:params] ||= {}

    properties
  end

  def request_env_by(request_method, url, raw_properties)

    properties = format_properties(raw_properties)
    URI.encode_www_form(properties[:params].to_a)

    {
        "REMOTE_ADDR"=>"192.168.56.1",
        "REQUEST_METHOD"=> request_method.to_s.upcase,
        "REQUEST_PATH" => url,
        "REQUEST_URI"=> url,
        "SERVER_PROTOCOL"=>"HTTP/1.1",
        "CONTENT_LENGTH"=>"0",
        "CONTENT_TYPE"=>"application/x-www-form-urlencoded",
        "SERVER_NAME"=>"hds-dev.ett.local",
        "SERVER_PORT"=>"80",
        "QUERY_STRING"=> URI.encode_www_form(properties[:params].to_a),
        "HTTP_VERSION"=>"HTTP/1.1",
        "HTTP_USER_AGENT"=>"spec",
        "HTTP_HOST"=>"spec.local",
        "HTTP_ACCEPT_ENCODING"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "HTTP_ACCEPT"=>"*/*",
        "HTTP_CONNECTION"=>"close"
    }

  end

end