class Rack::App::Router::Dynamic::RequestPathPartPlaceholder

  attr_reader :name
  def initialize(name)
    @name = name
    freeze
  end

  def ==(oth)
    oth.respond_to?(:name) && oth.name == @name
  end

end
