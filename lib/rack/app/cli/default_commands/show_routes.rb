class Rack::App::CLI::DefaultCommands::ShowRoutes < Rack::App::CLI::Command
  description 'list the routes for the application'

  on '-v', '--verbose', 'show endpoint definition paths too' do
    @verbose = true
  end

  FIELD_FETCHERS = {
    :request_method =>  proc { |endpoint| endpoint.request_method },
    :request_path =>  proc { |endpoint| endpoint.request_path },
    :description => proc { |endpoint| endpoint.description },
    :definition_path => proc do |endpoint|
      callable = endpoint.properties[:callable]
      (callable && callable.source_location.join(":") ) || ""
    end
  }.freeze

  action do
    endpoints = Rack::App::CLI.rack_app.router.endpoints
    sort_fields = %i[request_method request_path]
    sorted_endpoints = sort_by(endpoints, sort_fields)
    STDOUT.puts(format(sorted_endpoints))
  end

  private

  def get_fields
    fields = %i[request_method request_path description]
    fields << :definition_path if @verbose
    fields
  end

  def width_by(endpoints, fields)
    fields.each_with_object({}) do |property, widths|
      widths[property] = endpoints.map { |endpoint| FIELD_FETCHERS[property].call(endpoint).to_s.length }.max
    end
  end

  def sort_by(endpoints, sort_fields)
    endpoints.sort_by { |endpoint| sort_fields.map { |sf| FIELD_FETCHERS[sf].call(endpoint) } }
  end

  def format(endpoints)
    fields = get_fields
    widths = width_by(endpoints, fields)

    endpoints.map do |endpoint|
      fields.map do |field|
        FIELD_FETCHERS[field].call(endpoint).to_s.ljust(widths[field])
      end.join('   ')
    end.join("\n")
  end
end
