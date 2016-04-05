class Rack::App::CLI::Fetcher::Server < Rack::Server

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
