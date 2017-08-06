require 'rspec'
require 'yaml'
require 'pp'


rack_api_lib_folder = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift(rack_api_lib_folder)

# require "coverage.so"
# Coverage.start

# Kernel.at_exit do
#   result = Coverage.result.dup
#   pwd = Rack::App::Utils.pwd
#   spec_folder = File.dirname(__FILE__)

#   result.each_key do |key|
#     unless key.include?(pwd)
#       result.delete(key)
#     end

#     if key.include?(spec_folder)
#       result.delete(key)
#     end
#   end

#   result.select{|_, v| v.include?(0) }.each do |file_name, uses|
#     puts(file_name)
#     uses.each_with_index do |use, row|
#       puts row if use == 0
#     end
#   end

# end


require 'rack-app'


RSpec.configure do |config|

  config.include Rack::App::Test

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

end


# Dir.glob(File.join(File.dirname(__FILE__), 'support', '**', '*.rb')).each { |file_path| require(file_path) }

class BlockMiddlewareTester
  def initialize(app, k, &block)
    @app, @k, @block = app, k, block
  end

  def call(env)
    env[@k] = @block.call
    @app.call(env)
  end
end

class SampleMiddleware
  def initialize(app, k, v)
    @stack = app
    @k, @v = k, v
  end

  def call(env)
    env[@k.dup]= @v.dup
    @stack.call(env)
  end
end

module SampleMethods

  def hello_world
    'hello world'
  end

end

class SimpleExecMiddleware
  def initialize(app, callable)
    @app = app
    @callable = callable
  end

  def call(env)
    @callable.call(env)
    @app.call(env)
  end
end

class SimpleSetterMiddleware

  def initialize(app, k, v)
    @app, @k, @v = app, k, v
  end

  def call(env)
    env[@k] = @v
    @app.call(env)
  end

end

module RackMountTestApp
  extend(self)
  def call(env)
    path_info = env[::Rack::App::Constants::ENV::PATH_INFO]
    method_type = env['REQUEST_METHOD']
    Rack::Response.new(method_type + ':' + path_info).finish
  end
end

class RackBasedApplication

  def self.call(env)
    new.call(env)
  end

  def call(env)

    case env[::Rack::App::Constants::ENV::PATH_INFO]
    when '/'
      ['200', {'Content-Type' => 'text/html'}, ['static endpoint']]

    when /^\/users\/.*/
      ['200', {'Content-Type' => 'text/html'}, ['dynamic endpoint']]

    when '/hello/world/test/endpoint'
      ['200', {'Content-Type' => 'text/html'}, ['Hello, World!']]

    when /\/get_value\/\w+/
      ['200', {}, [env[env[::Rack::App::Constants::ENV::PATH_INFO].split("/")[-1]]]]

    else
      ['404', {}, ['404 Not Found: ' + env[::Rack::App::Constants::ENV::PATH_INFO].to_s]]

    end

  end

end

IS_OLD_RUBY = !(RUBY_VERSION[0..2] > '1.8')

class ExampleRackApp < Rack::App

  get '/' do
    '/'
  end

  get '/s' do
    '/s'
  end

  get '/d/:id' do
    "/d/#{params['id']}"
  end

  get '/path_to_root' do
    path_to '/'
  end

  get '/fetch/:env_value' do
    request.env[params['env_value']]
  end

end


class OthExampleRackApp < Rack::App

  get '/' do
    '/'
  end

end

PROJECT_ROOT_DIRECTORY = File.dirname(File.dirname(__FILE__))

def errpp(*args)
  PP.pp(*args, STDERR)
end