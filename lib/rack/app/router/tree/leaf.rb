# frozen_string_literal: true
class Rack::App::Router::Tree::Leaf < ::Hash
  require 'rack/app/router/tree/leaf/vein'

  def get(env)
    vein = vein_by(env)
    vein && vein.get(env)
  end

  def set(endpoint)
    endpoint.request_methods.each do |request_method|
      vein_for(request_method).set(endpoint)
    end
  end

  def struct
    hash = {}
    self.each do |request_method, vein|
      hash[request_method] = vein.struct
    end
    hash
  end

  protected

  def vein_by(env)
    self[env[Rack::App::Constants::ENV::REQUEST_METHOD].to_sym]
  end

  def vein_for(request_method)
    self[request_method] ||= Rack::App::Router::Tree::Leaf::Vein.new
  end

end
