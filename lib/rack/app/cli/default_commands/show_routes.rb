class Rack::App::CLI::DefaultCommands::ShowRoutes < Rack::App::CLI::Command

  description 'list the routes for the application'

  action do
    $stdout.puts(app.router.show_endpoints)
  end

  def app
    Rack::App::CLI.rack_app
  end

end