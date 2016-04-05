module Rack::App::CLI::Fetcher

  require 'rack/app/cli/fetcher/server'

  extend self

  module ExitPrevent

    def abort(*args)
    end

  end

  def rack_app

    server = Rack::App::CLI::Fetcher::Server.new(:config => 'config.ru')

    app = server.app

    until app.is_a?(Class) && app <= Rack::App
      app.instance_variables.each do |ivar|
        value = app.instance_variable_get(ivar)
        if value.respond_to?(:call) and not [Method, Proc, UnboundMethod].include?(value.class)
          app = value
        end
      end
    end

    app

  end

end
