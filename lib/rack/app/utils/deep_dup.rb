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

      when NilClass, Symbol, Numeric, TrueClass, FalseClass
        register_duplication(register, object, object)

      else
        dup_object(register, object)

    end
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
    dup_instance_variables(register, object, register_duplication(register, object, object.dup))
  end

  def dup_instance_variables(register, object, duplicate)
    object.instance_variables.each do |instance_variable|
      value = object.instance_variable_get(instance_variable)
      duplicate.instance_variable_set(instance_variable, dup(register, value))
    end

    return duplicate
  end

end