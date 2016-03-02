class Rack::App::Router::Dynamic < Rack::App::Router::Base

  PATH_PARAM = :"#{self}::PATH_PARAM".freeze
  PARTIAL = :"#{self}::PARTIAL".freeze

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

  protected

  def initialize
    @http_method_cluster = {}
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

  def compile_registered_endpoints!
    @http_method_cluster.clear
    endpoints.each do |endpoint_prop|
      compile_endpoint(endpoint_prop[:request_method],endpoint_prop[:request_path],endpoint_prop[:endpoint])
    end
  end

  def compile_endpoint(request_method, request_path, endpoint)

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
    if current_cluster[:endpoint].respond_to?(:register_path_params_matcher)
      current_cluster[:endpoint].register_path_params_matcher(path_params)
    end

    endpoint
  end

end