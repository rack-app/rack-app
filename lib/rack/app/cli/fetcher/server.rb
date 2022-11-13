require 'rackup/server'
class Rack::App::CLI::Fetcher::Server < ::Rackup::Server

  def get_rack_app
    app_class = self.app
    last_app = nil
    until app_class.is_a?(Class) && app_class <= Rack::App
      raise if app_class.__id__ == last_app.__id__

      app_class.instance_variables.each do |ivar|
        value = app_class.instance_variable_get(ivar)
        if value.respond_to?(:call) and not [Method, Proc, UnboundMethod].include?(value.class)
          app_class = value
        end
      end

      last_app = app_class
    end
    app_class
  rescue
  end

  Abort = Class.new(StandardError)

  def app
    super
  rescue Abort
    Class.new(Rack::App)
  end

  def abort(*messages)
    raise(Abort)
  end

  class Options
    def parse!(argv)
      {}
    end
  end

  def opt_parser
    Options.new
  end

end
