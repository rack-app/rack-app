require 'rack/app'
class RackApp < Rack::App

  get '/' do
    'hello'
  end

  500.times do |index|
    get "/#{index}" do
      'hello'
    end
  end

  500.times do |index|
    define_method("endpoint_helper_method_#{index}"){}
  end

end