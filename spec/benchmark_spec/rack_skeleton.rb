class RackSkeleton

  def self.call(env)
    new.call(env)
  end

  def call(env)

    request_path = env['REQUEST_PATH']

    case true

      when request_path == '/'
        ['200', {'Content-Type' => 'text/html'}, ['static endpoint']]

      when request_path =~ /^\/users\/\d+$/
        ['200', {'Content-Type' => 'text/html'}, ['dynamic endpoint']]

      else
        ['404', {}, ['404 Not Found']]

    end

  end

  500.times do |index|
    define_method("endpoint_helper_method_#{index}"){}
  end

end