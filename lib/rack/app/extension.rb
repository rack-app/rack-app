module Rack::App::Extension

  extend self

  def apply_extensions(app_class, *extension_names)
    extension_names.each do |extension_name|

      ext = find_extension_for(extension_name) || raise("Not registered extension name requested: #{extension_name}")
      app_class.class_eval(&ext)

    end
    nil
  end

  def register(extension_name, &builder_block)
    extension_registration_name = extension_name.to_s.to_sym
    extensions[extension_registration_name]= builder_block
    extension_registration_name
  end

  protected

  def extensions
    @extensions ||= {}
  end

  def find_extension_for(sym_name)
    return extensions[sym_name.to_s.to_sym]
  end

end