# frozen_string_literal: true
module Rack::App::InstanceMethods::PathTo
  def path_to(defined_path, options = {})
    app_class = options[:class] || self.class

    query_string_hash = options[:params] || {}
    options.each do |k, v|
      k.is_a?(String) && query_string_hash[k] = v
    end

    router = request.env[Rack::App::Constants::ENV::ROUTER]
    final_path = router.path_to(app_class, defined_path)

    path_keys = final_path.scan(/:(\w+)/).flatten

    path_keys.each do |key|
      value = query_string_hash.delete(key) || params[key] || raise("missing path-key value for #{key}!")
      final_path.gsub!(/:#{key}/, value.to_s)
    end

    unless query_string_hash.empty?
      final_path.concat("?" + Rack::App::Utils.encode_www_form(query_string_hash))
    end

    final_path
  end
end
