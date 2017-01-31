# frozen_string_literal: true
module Rack::App::Router::Tree::Env
  extend(self)

  E = Rack::App::Constants::ENV

  def configure(env)
    env[E::PATH_PARAMS] ||= {}
    env[E::FORMATTED_PATH_INFO] = Rack::App::Utils.normalize_path(env[E::PATH_INFO])
    env[E::EXTNAME] = File.extname(Rack::App::Utils.split_path_info(env[E::FORMATTED_PATH_INFO]).last)
    env[E::FORMATTED_PATH_INFO].slice!(/#{Regexp.escape(env[E::EXTNAME])}$/)
  end
end
