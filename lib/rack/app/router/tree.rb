# frozen_string_literal: true
class Rack::App::Router::Tree

  require 'rack/app/router/tree/env'

  require 'rack/app/router/tree/branch'
  require 'rack/app/router/tree/leaf'
  require 'rack/app/router/tree/vein'

  attr_reader :root

  def initialize
    @root = self.class::Branch.new
  end

  def add(endpoint)
    @root.set(self.class::Env.new(endpoint))
  end

  def call(env)
    configure_request(env)
    @root.call(env, *env[Rack::App::Constants::ENV::SPLITTED_PATH_INFO])
  end

  protected

  E = Rack::App::Constants::ENV

  def configure_request(env)
    env[E::PATH_PARAMS] ||= {}
    fpi = format_path_info(env).freeze
    env[E::FORMATTED_PATH_INFO] = fpi
    spi = split_path_info(fpi).freeze
    env[E::SPLITTED_PATH_INFO] = spi
    env[E::EXTNAME] = extname(spi)
  end

  def format_path_info(env)
    Rack::App::Utils.normalize_path(env[E::PATH_INFO])
  end

  def split_path_info(formatted_path_info)
    Rack::App::Utils.split_path_info(formatted_path_info)
  end

  def extname(splitted_path_info)
    File.extname(splitted_path_info.last)
  end

end
