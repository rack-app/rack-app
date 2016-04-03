module Rack::App::Extension

  extend self

  def apply_extensions(app_class, applied_ext_names, apply_ext_names)
    apply_ext_names.each do |extension_name|
      extension_name = format_extension_name(extension_name)

      next if applied_ext_names.include?(extension_name)
      applied_ext_names << extension_name

      ext = find_extension_for(extension_name)
      app_class.class_eval(&ext)

    end
    nil
  end

  def format_extension_name(extension_name)
    extension_name.to_s.to_sym
  end

  def register(extension_name, &builder_block)
    extensions[format_extension_name(extension_name)]= builder_block
  end

  protected

  def extensions
    @extensions ||= {}
  end

  def find_extension_for(sym_name)
    return extensions[sym_name.to_s.to_sym] || raise("Not registered extension name requested: #{sym_name}")
  end

end