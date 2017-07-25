class Rack::App::Router::Error < StandardError
  AppIsNotMountedInTheRouter = Class.new(self)
  MountedAppDoesNotHaveThisPath = Class.new(self)
end
