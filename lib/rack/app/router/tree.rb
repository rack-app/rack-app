# frozen_string_literal: true
class Rack::App::Router::Tree

  require 'rack/app/router/tree/env'
  require 'rack/app/router/tree/node'
  require 'rack/app/router/tree/leaf'
  require 'rack/app/router/tree/mounted'

  def initialize
    @root = self.class::Node.new
  end

  def add(endpoint)
    @root.set(endpoint, *path_info_parts_by(endpoint.request_path))
  end

  def call(env)
    self.class::Env.configure(env)
    @root.get(env, *path_info_parts_by(env[Rack::App::Constants::ENV::FORMATTED_PATH_INFO]))
  end

  protected

  def request_methods(endpoint)
    case endpoint.request_method
    when ::Rack::App::Constants::HTTP::METHOD::ANY
      ::Rack::App::Constants::HTTP::METHODS.each{|m| yield(m) }
    else
      yield(endpoint.request_method)
    end
  end

  def cluster(request_method)
    @methods[request_method.to_s.upcase] ||= Rack::App::Router::Tree::Node.new
  end

  def path_info_parts_by(path_info)
    Rack::App::Utils.split_path_info(Rack::App::Utils.normalize_path(path_info))
  end
end
