class Rack::App::Utils::DeepDup

  def initialize(object)
    @object = object
  end

  def to_dup
    @register = {}

    dup(@object)
  end

  protected

  def registration(object, duplicate)
    @register[object.object_id]= duplicate
    duplicate
  end

  def registered(object)
    @register[object.object_id]
  end

  def dup(object)

    return registered(object) if registered(object)

    case object

      when Array
        dup_array(object)

      when Hash
        dup_hash(object)

      when Range
        dup_range(object)

      when Struct
        dup_struct(object)

      when NilClass, Symbol, Numeric, TrueClass, FalseClass
        registration(object, object)

      else
        dup_object(object)

    end
  end

  def dup_array(object)
    duplication = dup_object(object)
    duplication.map!{ |e| dup(e) }
  end

  def dup_hash(object)
    duplication = dup_object(object)
    object.reduce(duplication) { |hash, (k, v)| hash.merge!(dup(k) => dup(v)) }
  end

  def dup_range(range)
    registration(range, range.class.new(dup(range.first), dup(range.last)))
  rescue
    registration(range, range.dup)
  end

  def dup_struct(struct)
    duplication = registration(struct, struct.dup)

    struct.each_pair do |attr, value|
      duplication.__send__("#{attr}=", dup(value))
    end

    duplication
  end

  def dup_object(object)
    dup_instance_variables(object, registration(object, object.dup))
  end

  def dup_instance_variables(object, duplicate)
    object.instance_variables.each do |instance_variable|
      value = object.instance_variable_get(instance_variable)
      duplicate.instance_variable_set(instance_variable, dup(value))
    end

    return duplicate
  end

end