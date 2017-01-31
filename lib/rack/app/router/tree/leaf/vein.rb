# frozen_string_literal: true
class Rack::App::Router::Tree::Leaf::Vein < ::Hash

  E = Rack::App::Constants::ENV

  def set(endpoint)
    app = endpoint.to_app
    endpoint.config.serializer.extnames.each do |extname|
      self[extname] = app
    end
    self[extname_for(endpoint)] = app
  end

  def get(env)
    app = self[env[E::EXTNAME]]
    app && app.call(env)
  end

  def struct
    self.reduce({}) do |hash, (extname, app)|
      hash[extname]= :app
      hash
    end
  end

  protected

  def extname_for(endpoint)
    File.extname(Rack::App::Utils.split_path_info(endpoint.request_path).last)
  end
end
