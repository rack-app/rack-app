# frozen_string_literal: true
class Rack::App::Router::Tree::Branch < ::Hash

  def set(env)
    if env.branch?
      branch_for(env.save_key).set(env.next)
    else
      leaf.set(env)
    end
  end

  def call(env, current, *path_info_parts)
    if path_info_parts.empty?
      try_leaf { |l| l.call_endpoint(env, current) || l.call_mount(env)  }
    else
      next_branch = self[current] || self[:ANY]
      resp = next_branch && next_branch.call(env, *path_info_parts)
      resp || try_leaf { |l| l.call_mount(env) }
    end
  end

  protected

  def try_leaf
    leaf = self[:LEAF]
    leaf && yield(leaf)
  end

  def branch_for(save_key)
    self[save_key] ||= self.class.new
  end

  def leaf
    self[:LEAF] ||= Rack::App::Router::Tree::Leaf.new
  end

end
