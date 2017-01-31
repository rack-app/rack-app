# frozen_string_literal: true
class Rack::App::Router::Tree::Mounted

  require 'rack/app/router/tree/mounted/application'

  def get(env)
    @app.call(env)
  end

  protected

  def initialize(endpoint)
    @app = endpoint.to_app
  end

end
