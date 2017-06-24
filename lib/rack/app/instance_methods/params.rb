module Rack::App::InstanceMethods::Params

  E = ::Rack::App::Constants::ENV

  def params
    request.env[E::PARAMS].to_hash
  end

  def validated_params
    request.env[E::PARAMS].validated_params
  end

  Rack::App::Utils.deprecate(self, :validated_params, :params, 2017, 07)

  def path_segments_params
    request.env[E::PARAMS].path_segments_params
  end

  def query_string_params
    request.env[E::PARAMS].query_string_params
  end

end
