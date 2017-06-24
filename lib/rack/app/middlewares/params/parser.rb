class Rack::App::Middlewares::Params::Parser

  def initialize(app, descriptor)
    @app = app
    @descriptor = descriptor
    @merged_params_descriptor = descriptor.values.reduce(:merge)
  end

  def call(env)
    set_params(env)

    @app.call(env)
  end

  protected

  def set_params(env)
    params = Rack::App::Params.new(env).merged_params
    validated_params = (env[::Rack::App::Constants::ENV::VALIDATED_PARAMS] ||= {})
    parse_params(validated_params, params)
  end

  def parse_params(validated_params, params)
    @merged_params_descriptor.each do |key, properties|
      next if params[key].nil?

      if properties[:of]
        validated_params[key]= [*params[key]].map{ |str| parse(properties[:of], str) }
      else
        validated_params[key]= parse(properties[:class], params[key])
      end

    end
  end

  def parse(type, str)
    Rack::App::Utils::Parser.parse(type, str)
  end

end
