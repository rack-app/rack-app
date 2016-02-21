module UtilsSpecHelper
  extend self

  def expand_path(file_path)
    return Rack::App::Utils.expand_path(file_path)
  end

end