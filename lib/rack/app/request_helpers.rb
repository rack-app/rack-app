module Rack::App::RequestHelpers

  require 'rack/app/request_helper/params'

  def params
    @__request_params__ ||= Rack::App::RequestHelpers::Params.new(request.env).to_hash
  end

  def status(new_status=nil)
    response.status= new_status.to_i unless new_status.nil?

    response.status
  end

end