require "rack/request"
class Rack::App::Request < ::Rack::Request

  def params
    @env[::Rack::App::Constants::ENV::PARAMS].to_hash
  end

  def path_segments_params
    @env[::Rack::App::Constants::ENV::PARAMS].path_segments_params
  end

  def query_string_params
    @env[::Rack::App::Constants::ENV::PARAMS].query_string_params
  end

end
