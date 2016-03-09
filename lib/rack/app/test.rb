require 'uri'
require 'rack/app'
module Rack::App::Test

  require 'rack/app/test/utils'

  def self.included(klass)
    klass.__send__(:extend,SpecHelpers)
  end

  module SpecHelpers

    def rack_app(*args,&constructor)

      begin
        let(:rack_app){ rack_app_by(*args,&constructor) }
      rescue NoMethodError
        define_method(:rack_app) do
          rack_app_by(*args,&constructor)
        end
      end

    end

  end

  def rack_app_by(*args,&constructor)
    subject_app = nil
    rack_app_class = args.shift

    if constructor.nil?
      subject_app = rack_app_class
    else
      subject_app = Class.new(rack_app_class || Rack::App)
      subject_app.class_eval(&constructor)
    end

    subject_app
  end

  [:get, :post, :put, :delete, :options, :patch].each do |request_method|
    define_method(request_method) do |properties|
      properties ||= Hash.new
      url = properties.delete(:url)
      request_env = Rack::App::Test::Utils.request_env_by(request_method, url, properties)
      raw_response = rack_app.call(request_env)

      body = []
      raw_response[2].each do |e|
        body << e
      end

      return Rack::Response.new(body,raw_response[0],raw_response[1])
    end
  end

end