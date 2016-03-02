module Rack::App::InstanceMethods

  attr_writer :request, :response

  def params
    @__params__ ||= Rack::App::Params.new(request.env).to_hash
  end

  def request
    @request || raise("request object is not set for #{self.class}")
  end

  def response
    @response || raise("response object is not set for #{self.class}")
  end

  def payload
    @__payload__ ||= lambda {
      return nil unless @request.body.respond_to?(:gets)

      payload = ''
      while chunk = @request.body.gets
        payload << chunk
      end
      @request.body.rewind

      return payload
    }.call
  end

  def redirect_to(url)
    url = "#{url}?#{request.env['QUERY_STRING']}" unless request.env['QUERY_STRING'].empty?
    response.status = 301
    response.headers.merge!({'Location' => url})
    'See Ya!'
  end

end
