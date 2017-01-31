# frozen_string_literal: true
class Rack::App::Router::Tree::Node < ::Hash

  PARAM = :PARAM

  def set(endpoint, current=nil, *path_info_parts)
    case type(current)
    when :NODE
      node_for(save_key(current)).set(endpoint, *path_info_parts)
    when :LEAF
      save_to_leaf(endpoint)
    when :RACK_BASED_APPLICATION
      attach(:RACK_BASED_APPLICATION, Rack::App::Router::Tree::Mounted::Application.new(endpoint))
    when :MOUNTED
      attach(:MOUNT, Rack::App::Router::Tree::Mounted.new(endpoint))
    else
      raise('UNKNOWN')
    end
  end

  def get(env, current=nil, *path_info_parts)
    return app_for(env) if current.nil?
    node = next_node(env, current)
    (node && node.get(env, *path_info_parts)) || mounted(env)
  end

  def struct
    self.reduce({}) do |hash, (k,v)|
      if k == PARAM
        hash[k] = v
      else
        hash[k] = v.struct
      end
      hash
    end
  end

  protected

  def app_for(env)
    app = self[:LEAF] || mounted_app
    app && app.get(env)
  end

  def mounted(env)
    mounted_app && mounted_app.get(env)
  end

  def mounted_app
    self[:MOUNT] || self[:RACK_BASED_APPLICATION]
  end

  def attach(key, app_or_endpoint)
    self[key.to_sym] = app_or_endpoint
  end

  def save_to_leaf(endpoint)
    self[:LEAF] ||= Rack::App::Router::Tree::Leaf.new
    self[:LEAF].set(endpoint)
  end

  def next_node(env, current)
    self[current] || any_path(env, current)
  end

  def any_path(env, current)
    if self[:ANY]
      env[Rack::App::Constants::ENV::PATH_PARAMS][self[PARAM]] = current
      self[:ANY]
    end
  end

  def node_for(key)
    self[key] ||= self.class.new
  end

  def type(current)
    case current
    when Rack::App::Constants::RACK_BASED_APPLICATION
      :RACK_BASED_APPLICATION
    when '**','*'
      :MOUNTED
    when NilClass
      :LEAF
    else
      :NODE
    end
  end

  def save_key(path)
    case path
    when /^:\w+$/i
      self[PARAM] = path.sub(/^:/, '')
      :ANY
    else
      extnameless(path)
    end
  end

  def extnameless(path)
    path.sub(/\.\w+$/,'')
  end

end
