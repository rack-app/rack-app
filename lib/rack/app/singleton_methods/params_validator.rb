module Rack::App::SingletonMethods::ParamsValidator
  def validate_params(&block)
    descriptor = Rack::App::Middlewares::Params::Definition.new(&block).to_descriptor
    route_registration_properties[:params]= descriptor
    only_next_endpoint_middlewares do |builder|
      builder.use(Rack::App::Middlewares::Params::Setter)
      builder.use(Rack::App::Middlewares::Params::Validator, descriptor)
      builder.use(Rack::App::Middlewares::Params::Parser, descriptor)
    end
  end
  alias params validate_params
end
