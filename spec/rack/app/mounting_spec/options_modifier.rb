class OptionsModifier < Rack::App


  on_mounted do |options|
    options.delete(options[:delete])
  end

  on_mounted do |options|

    get options[:endpoint] do
      options[:endpoint]
    end

  end

end