class Rack::App::Router::Dynamic

  PATH_PARAM = :"#{self}::PATH_PARAM".freeze
  PARTIAL = :"#{self}::PARTIAL".freeze

  # def endpoint_paths
  # end

  def add_endpoint(request_method, request_path, endpoint)
    request_path = Rack::App::Utils.normalize_path(request_path)
    @endpoint_paths << [request_method, request_path]

    current_cluster = main_cluster(request_method)
    path_params = {}
    break_build = false

    request_path.split('/').each.with_index do |path_part, index|

      new_cluster_name = if path_part_is_dynamic?(path_part)
                           path_params[index]= path_part.sub(/^:/, '')
                           PATH_PARAM

                         elsif path_part_is_a_partial?(path_part)
                           break_build = true
                           PARTIAL

                         else
                           path_part
                         end

      current_cluster = (current_cluster[new_cluster_name] ||= {})
      break if break_build

    end

    current_cluster[:endpoint]= endpoint
    current_cluster[:endpoint].register_path_params_matcher(path_params)

    endpoint
  end

  def fetch_endpoint(request_method, request_path)
    normalized_request_path = Rack::App::Utils.normalize_path(request_path)

    current_cluster = main_cluster(request_method)
    normalized_request_path.split('/').each do |path_part|
      previous_cluster = current_cluster
      current_cluster = current_cluster[path_part] || current_cluster[PATH_PARAM]
      if current_cluster.nil?
        if previous_cluster[PARTIAL]
          current_cluster = previous_cluster[PARTIAL]
          break
        else
          return nil
        end
      end
    end

    current_cluster[:endpoint]
  end

  def merge!(router)
    raise(ArgumentError, "invalid route object, must be instance of #{self.class.to_s}") unless router.is_a?(self.class)
    deep_merge!(@http_method_cluster, router.instance_variable_get(:@http_method_cluster))
    nil
  end

  protected

  def initialize
    @http_method_cluster = {}
    @endpoint_paths = []
  end

  def path_part_is_dynamic?(path_part_str)
    !!(path_part_str.to_s =~ /^:\w+$/i)
  end

  def deep_merge!(hash, other_hash)
    other_hash.each_pair do |current_key, other_value|

      this_value = hash[current_key]

      hash[current_key] = if this_value.is_a?(Hash) && other_value.is_a?(Hash)
                            deep_merge!(this_value, other_value)
                          else
                            other_value
                          end
    end

    hash
  end

  def main_cluster(request_method)
    (@http_method_cluster[request_method.to_s.upcase] ||= {})
  end

  def path_part_is_a_partial?(path_part)
    (path_part == '**' or path_part == '*')
  end

end