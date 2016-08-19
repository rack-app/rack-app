module Rack::App::CLI::Fetcher

  require 'rack/app/cli/fetcher/server'

  extend self

  module ExitPrevent

    def abort(*args)
    end

  end

  def rack_app
    server_based_lookup || rack_app_with_most_endpoints
  end

  protected

  def server_based_lookup
    @server_based_lookup ||= lambda do
      server = Rack::App::CLI::Fetcher::Server.new(:config => 'config.ru')
      app = server.app
      last_app = nil
      until app.is_a?(Class) && app <= Rack::App
        raise if app.__id__ == last_app.__id__

        app.instance_variables.each do |ivar|
          value = app.instance_variable_get(ivar)
          if value.respond_to?(:call) and not [Method, Proc, UnboundMethod].include?(value.class)
            app = value
          end
        end

        last_app = app
      end
      app
    end.call 
  rescue
  end

  def rack_app_with_most_endpoints
    ObjectSpace.each_object(Class).select{|klass|
      klass < Rack::App
    }.uniq.sort_by{ |rack_app|
      rack_app.router.endpoints.length
    }.last
  end

end
