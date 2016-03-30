require 'rack/app'
class OnMountSelfModifyingApp < Rack::App

  on_mounted do |options|

    def self.new_method
      'singleton_method_definition'
    end

    def new_method
      'instance_method_definition'
    end

    get "/#{options[:endpoint]}" do
      'works!'
    end

    namespace options[:endpoint] do

      get '/singleton' do
        self.class.new_method
      end

      get '/instance' do
        self.new_method
      end

    end

  end

end