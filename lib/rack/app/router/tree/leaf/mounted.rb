# frozen_string_literal: true
class Rack::App::Router::Tree::Leaf::Mounted

  require 'rack/app/router/tree/leaf/mounted/application'

  def call(env)
    @app.call(env)
  end

  protected

  def initialize(endpoint)
    @app = endpoint.to_app
  end

end
