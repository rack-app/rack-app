#!/usr/bin/env ruby
# frozen_string_literal: true

rack_api_lib_folder = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift(rack_api_lib_folder)
require 'rack/app'
require 'pp'

tree = Rack::App::Router::Tree.new

APP = Class.new(Rack::App)

payload = Rack::App::Payload::Builder.new

payload.parser_builder do
  accept :json
end

serializer = Rack::App::Serializer::FormatsBuilder.new
serializer.instance_exec do
    on '.json', 'application/json' do |obj|
        JSON.dump(obj)
    end
end

endpoint = Rack::App::Endpoint.new(
  :route => {},
  :app_class => APP,
  :request_methods => ["GET"],
  :request_path => '/hello/world/:id',
  :middleware_builders_blocks => [],
  :user_defined_logic => proc{ "hy" },
  :serializer_builder => serializer,
  :payload => payload,
  :error_handler => Rack::App::ErrorHandler.new,
)


properties = {
    :request_methods => ::Rack::App::Constants::HTTP::METHODS,
    :request_path => Rack::App::Utils.join("hello", ::Rack::App::Constants::RACK_BASED_APPLICATION),
    :application => proc{|env| Rack::Response.new.finish }
}

tree.add(Rack::App::Endpoint.new(properties))

endpoint = Rack::App::Endpoint.new(
  :route => {},
  :app_class => APP,
  :request_methods => ["GET"],
  :request_path => '/hello/world/:id',
  :middleware_builders_blocks => [],
  :user_defined_logic => proc{ "hy" },
  :serializer_builder => serializer,
  :payload => payload,
  :error_handler => Rack::App::ErrorHandler.new,
)

tree.add(endpoint)
pp tree

require 'rack'
puts

[
    "/hello/world/123.json",
    "/hello/world/123",
    "/hello/world",
].each do |path_info|
    env = Rack::MockRequest.env_for(path_info, :method => 'GET')
    resp = tree.call(env)

    puts(path_info)
    p resp.is_a?(Array) && resp.length == 3
    puts
end
