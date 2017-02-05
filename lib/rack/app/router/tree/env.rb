# frozen_string_literal: true
class Rack::App::Router::Tree::Env

  attr_reader :request_path_parts, :endpoint, :params

  def current
    @request_path_parts[@index]
  end

  def branch?
    !clean_request_path_parts[@index..-2].empty?
  end

  def type
    case @request_path_parts.last
    when Rack::App::Constants::PATH::APPLICATION
      :APPLICATION
    when Rack::App::Constants::PATH::MOUNT_POINT
      :MOUNT_POINT
    else
      :ENDPOINT
    end
  end

  def save_key
    if current =~ /^:\w+$/i
      @params[@index]= current.sub(/^:/, '')
      :ANY
    else
      current
    end
  end

  def next
    env = self.dup
    env.inc_index!
    env
  end

  protected

  def initialize(endpoint)
    @index = 0
    @params = {}
    @endpoint = endpoint
    @request_path_parts = request_path_parts_by(endpoint).freeze
  end

  def request_path_parts_by(endpoint)
    u = Rack::App::Utils
    u.split_path_info(u.normalize_path(endpoint.request_path))
  end

  def inc_index!
    @index += 1
  end

  SPECIAL_PATH_ELEMENTS = [
    Rack::App::Constants::PATH::APPLICATION,
    Rack::App::Constants::PATH::MOUNT_POINT
  ].freeze

  def clean_request_path_parts
    @request_path_parts - SPECIAL_PATH_ELEMENTS
  end

end
