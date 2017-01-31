# frozen_string_literal: true
class Rack::App::Router::Tree::Mounted::Application < Rack::App::Router::Tree::Mounted
  protected

  def initialize(endpoint)
    @app = build(endpoint)
  end

  def build(endpoint)
    builder = Rack::Builder.new
    builder.use(Rack::App::Middlewares::PathInfoCutter, mount_path(endpoint))
    builder.run(endpoint.to_app)
    builder.to_app
  end

  def mount_path(endpoint)
    mount_path_parts = (endpoint.request_path.split('/') - [Rack::App::Constants::RACK_BASED_APPLICATION, ''])
    mount_path_parts.empty? ? '' : Rack::App::Utils.join(mount_path_parts)
  end
end
