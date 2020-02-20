class Rack::App::Middlewares::Params::Validator
  ValidateError = Class.new(ArgumentError)

  def initialize(app, descriptor)
    @descriptor = descriptor
    @app = app
  end

  # => 422 required field missing | "422 Unprocessable Entity"
  def call(env)
    validate(env)
    @app.call(env)
  rescue ValidateError => ex
    unprocessable_response(ex)
  end

  protected

  def unprocessable_response(validate_error)
    response = Rack::Response.new
    response.status = 422
    response.write("422 Unprocessable Entity\n")
    response.write(validate_error.message)
    response.finish
  end

  def validate(env)
    params = Rack::App::Params.new(env).merged_params
    validation_results(env, params)
  end

  def validation_results(env, params)
    validate_required_params(env, params)
    validate_optional_params(env, params)
    validate_invalid_params(params)
  end

  def validate_required_params(env, params)
    @descriptor[:required].each do |key, properties|
      validate_key(key, properties, params)
    end
  end

  def validate_optional_params(env, params)
    @descriptor[:optional].each do |key, properties|
      next unless params.key?(key)

      validate_key(key, properties, params)
    end
  end

  def validate_key(key, properties, params)
    missing_key_error(key, properties[:class]) unless params.key?(key)

    if properties[:of]
      validate_array(properties[:class], properties[:of], key, *params[key])
    elsif parse(properties[:class], params[key]).nil?
      invalid_type_error(key, properties[:class])
    end
  end

  def validate_invalid_params(params)
    valid_keys = @descriptor[:required].keys + @descriptor[:optional].keys
    (params.keys - valid_keys).each do |key|
      invalid_key_error(key)
    end
  end

  def validate_array(type, elements_type, key, *elements)
    values = elements.map { |str| parse(elements_type, str) }

    if values.include?(nil)
      invalid_type_of_error(key, type, elements_type)
    end
  end

  def parse(type, str)
    ::Rack::App::Utils::Parser.parse(type, str)
  end

  def error(message)
    raise(ValidateError.new(message))
  end

  def missing_key_error(key, klass)
    error "missing key: #{key}(#{klass})"
  end

  def invalid_key_error(key)
    error "invalid key: #{key}"
  end

  def invalid_type_error(key, klass)
    error "invalid type for #{key}: #{klass} expected"
  end

  def invalid_type_of_error(key, klass, of)
    error "invalid type for #{key}: #{klass} of #{of} expected"
  end
end
