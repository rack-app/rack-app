module Rack::App::Extension::Factory

  extend self

  def all
    ObjectSpace.each_object(Class).select { |klass| klass < ::Rack::App::Extension }
  end

  def find_for(sym_name)
    return all.find{|extension_class| extension_class.names.include?(sym_name) }
  end

end