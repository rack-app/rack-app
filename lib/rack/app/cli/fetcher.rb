module Rack::App::CLI::Fetcher

  require 'rack/app/cli/fetcher/server'

  extend self

  module ExitPrevent

    def abort(*args)
    end

  end

  def rack_app
    @rack_app ||= (server_based_lookup || rack_app_with_most_endpoints)
  end

  protected

  def server_based_lookup
     Rack::App::CLI::Fetcher::Server.new(:config => 'config.ru').get_rack_app
  end

  def rack_app_with_most_endpoints
    ObjectSpace.each_object(Class).select{|klass|
      klass < Rack::App
    }.uniq.sort_by{ |rack_app|
      rack_app.router.endpoints.length
    }.last
  end

end
