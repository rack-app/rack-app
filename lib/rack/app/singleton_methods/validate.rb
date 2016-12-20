module Rack::App::SingletonMethods::Validate

  def validate(&assertation_block)
    if block_given?
      route_registration_properties[:validations] ||= []
      route_registration_properties[:validations] << assertation_block
      next_endpoint_middlewares do |builder|
        builder.use(Rack::App::Middlewares::Validate, assertation_block)
      end
    end
  end

end
