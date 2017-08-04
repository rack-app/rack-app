class Rack::App::CLI::DefaultCommands::ShowRoutes < Rack::App::CLI::Command
  description 'list the routes for the application'

  on '-v', '--verbose', 'print out everything' do
    @verbose = true
  end

  on '-d', '--desc', '--description', 'include endpoint descriptions too' do
    @description = true
  end

  on '-l', '--location', '--source-location', 'show endpoint definition locations' do
    @source_location = true
  end

  on '-m', '--middlewares', 'show endpoint definition middleware stack' do
    @middlewares = true
  end

  FIELD_FETCHERS = {
    :request_method =>  proc { |endpoint| endpoint.request_method },
    :request_path =>  proc { |endpoint| endpoint.request_path },
    :description => proc { |endpoint| endpoint.description },
    :source_location => proc do |endpoint|
      callable = endpoint.properties[:callable]
      callable = callable.method(:call) unless callable.is_a?(::Proc)
      callable.source_location.join(':')
    end
  }.freeze

  SORT_FIELDS = [:request_method, :request_path].freeze

  action do
    STDOUT.puts(format(sort(Rack::App::CLI.rack_app.router.endpoints)))
  end

  private


  def get_fields
    if @verbose
      return FIELD_FETCHERS.keys
    end

    fields = [:request_method, :request_path]
    fields << :description if @description
    fields << :source_location if @source_location
    fields
  end

  def width_by(endpoints, fields)
    fields.each_with_object({}) do |property, widths|
      widths[property] = endpoints.map { |endpoint| FIELD_FETCHERS[property].call(endpoint).to_s.length }.max
    end
  end


  def sort(endpoints)
    endpoints.sort_by { |endpoint| SORT_FIELDS.map { |sf| FIELD_FETCHERS[sf].call(endpoint) } }
  end

  def format(endpoints)
    fields = get_fields
    widths = width_by(endpoints, fields)

    endpoints.map do |endpoint|
      outputs = []

      outputs << fields.map do |field|
        FIELD_FETCHERS[field].call(endpoint).to_s.ljust(widths[field])
      end.join('   ')

      if @middlewares
        outputs << pretty_print_middlewares(endpoint)
      end

      outputs.join("\n")
    end.join("\n")
  end

  class FakeBuilder
    attr_reader :middlewares

    def initialize
      @middlewares = []
    end

    def use(middleware, *args)
      @middlewares << middleware
    end
  end

  def pretty_print_middlewares(endpoint)
    builder = FakeBuilder.new

    endpoint.config.middlewares.each do |builder_block|
      builder.instance_exec(builder, &builder_block)
    end

    builder.middlewares.map do |middleware|
      ["\t", '* ', middleware].join
    end.join("\n")
  end

end
