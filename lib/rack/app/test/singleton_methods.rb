module Rack::App::Test::SingletonMethods

  def rack_app(*args, &constructor)

    begin
      let(:rack_app) { Rack::App::Test::Utils.rack_app_by(*args, &constructor) }
    rescue NoMethodError
      define_method(:rack_app) do
        rack_app_by(*args, &constructor)
      end
    end

  end

end