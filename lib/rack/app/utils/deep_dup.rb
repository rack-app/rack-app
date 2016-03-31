module Rack::App::Utils::DeepDup

  extend self

  def duplicate(object)
    register = {}

    dup(register, object)
  end

  protected

  def registered(object, register)
    register[object.object_id]
  end

  def register_duplication(register, object, duplicate)
    register[object.object_id]= duplicate
    duplicate
  end

  def dup(register, object)

    return object unless registrable?(object)
    return registered(object, register) if registered(object, register)

    case object

      when Array
        dup_array(register, object)

      when Hash
        dup_hash(register, object)

      when Range
        dup_range(register, object)

      when Struct
        dup_struct(register, object)

      when NilClass, Symbol, Numeric, TrueClass, FalseClass, Method
        register_duplication(register, object, object)

      else
        dup_object(register, object)

    end
  end

  def registrable?(object)
    object.object_id
    true
  rescue NoMethodError
    false
  end

  def dup_array(register, object)
    duplication = dup_object(register, object)
    duplication.map! { |e| dup(register, e) }
  end

  def dup_hash(register, object)
    duplication = dup_object(register, object)
    object.reduce(duplication) { |hash, (k, v)| hash.merge!(dup(register, k) => dup(register, v)) }
  end

  def dup_range(register, range)
    register_duplication(register, range, range.class.new(dup(register, range.first), dup(register, range.last)))
  rescue
    register_duplication(register, range, range.dup)
  end

  def dup_struct(register, struct)
    duplication = register_duplication(register, struct, struct.dup)

    struct.each_pair do |attr, value|
      duplication.__send__("#{attr}=", dup(register, value))
    end

    duplication
  end

  def dup_object(register, object)
    dup_instance_variables(register, object, register_duplication(register, object, try_dup(object)))
  end

  def dup_instance_variables(register, object, duplication)
    return duplication unless respond_to_instance_variables?(object)

    object.instance_variables.each do |instance_variable|
      value = get_instance_variable(object, instance_variable)

      set_instance_variable(duplication, instance_variable, dup(register, value))
    end

    return duplication
  end

  def get_instance_variable(object, instance_variable_name)
    object.instance_variable_get(instance_variable_name)
  rescue NoMethodError
    object.instance_eval("#{instance_variable_name}")
  end

  def set_instance_variable(duplicate, instance_variable_name, value_to_set)
    duplicate.instance_variable_set(instance_variable_name, value_to_set)
  rescue NoMethodError
    duplicate.instance_eval("#{instance_variable_name} = Marshal.load(#{Marshal.dump(value_to_set).inspect})")
  end

  def try_dup(object)
    object.dup
  rescue NoMethodError, TypeError
    object
  end

  def respond_to_instance_variables?(object)
    object.respond_to?(:instance_variables)
  rescue NoMethodError
    false
  end

end