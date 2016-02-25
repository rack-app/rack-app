require 'spec_helper'
require 'rack/app/test'

class SimpleSetterMiddleware

  def initialize(app, k, v)
    @app, @k, @v = app, k, v
  end

  def call(env)
    env[@k] = @v
    @app.call(env)
  end

end

class RackAppInheritanceParent < Rack::App

  EXCEPTION = Class.new(Exception)

  middleware do |b|
    b.use SimpleSetterMiddleware, 'parent', 'yes'
  end

  error EXCEPTION do |ex|
    ex.message
  end

  serializer do |object|
    object.inspect
  end

  headers 'Access-Control-Allow-Origin' => '*'

  get '/parent_endpoint' do
    'nope this is not in child'
  end

  def raise_error(msg)
    raise(EXCEPTION, msg.to_s)
  end

end

class RackAppInheritanceChild < RackAppInheritanceParent

  middleware do |b|
    b.use SimpleSetterMiddleware, 'child', 'true'
  end

  get '/error' do
    raise_error('error with parent class method')
  end

  get '/serialized' do
    'this is serialized from parent'
  end

  get '/mw_parent' do
    request.env['parent']
  end

  get '/mw_child' do
    request.env['child']
  end

  get '/Access-Control-Allow-Origin' do
    response.header['Access-Control-Allow-Origin']
  end

end

describe Rack::App do
  include Rack::App::Test
  describe '.inherited' do

    rack_app RackAppInheritanceChild

    it { expect(get(:url => '/parent_endpoint').status).to eq 404 }

    it { expect(get(:url => '/error').body.join).to eq 'error with parent class method'.inspect }

    it { expect(get(:url => '/serialized').body.join).to eq 'this is serialized from parent'.inspect }

    it { expect(get(:url => '/mw_parent').body.join).to eq 'yes'.inspect }

    it { expect(get(:url => '/mw_child').body.join).to eq 'true'.inspect }

    it { expect(get(:url => '/Access-Control-Allow-Origin').body.join).to eq '*'.inspect }

  end
end