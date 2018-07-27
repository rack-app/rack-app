# frozen_string_literal: true
class Rack::App::Router::Tree::Leaf < ::Hash

  require 'rack/app/router/tree/leaf/mounted'

  E = Rack::App::Constants::ENV

  def set(env)
    case env.type
    when :APPLICATION
      self[env.type] = Rack::App::Router::Tree::Leaf::Mounted::Application.new(env.endpoint)
    when :MOUNT_POINT
      self[env.type] = Rack::App::Router::Tree::Leaf::Mounted.new(env.endpoint)
    else
      save_endpoint(env)
    end
  end

  def call_endpoint(env, current_path)
    app = self[current_path] || self[:ANY]
    (app && app.call(env)) || call_mount(env)
  end

  def call_mount(env)
    app = self[:MOUNT_POINT] || self[:APPLICATION]
    app && app.call(env)
  end

  protected

  def save_endpoint(env)
    if env.save_key.is_a?(Symbol)
      vein_for(env.save_key).set(env)
    else
      split_save_to_extnames(env)
    end
  end

  def split_save_to_extnames(env)
    save_key = env.save_key
    env.endpoint.config.serializer.extnames.each do |extname|
      vein_for(save_key + extname).set(env)
    end
    vein_for(save_key).set(env)
  end

  def vein_for(path_part)
    self[path_part] ||= Rack::App::Router::Tree::Vein.new
  end

end
