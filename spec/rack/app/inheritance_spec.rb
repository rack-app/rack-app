require 'spec_helper'
require 'rack/app/test'

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

  get '/' do
    'root endpoint'
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

end

describe Rack::App do
  include Rack::App::Test
  describe '.inherited' do

    rack_app RackAppInheritanceChild

    it { expect(get(:url => '/parent_endpoint').status).to eq 404 }

    it { expect(get(:url => '/error').body).to eq 'error with parent class method'.inspect }

    it { expect(get(:url => '/serialized').body).to eq 'this is serialized from parent'.inspect }

    it { expect(get(:url => '/mw_parent').body).to eq 'yes'.inspect }

    it { expect(get(:url => '/mw_child').body).to eq 'true'.inspect }

    it { expect(get(:url => '/').headers['Access-Control-Allow-Origin']).to eq '*' }

    context 'when on_inheritance block defined in parent' do

      before do
        parent = RackAppInheritanceChild

        parent.class_eval do
          on_inheritance do |parent, child|
            child.instance_variable_set(:@dog, 'bark')
          end

          on_inheritance do |parent, child|
            child.instance_variable_set(:@cat, 'meow')
          end
        end

      end

      it 'should fire the registered on_inheritance blocks on inheritance' do
        child = Class.new(RackAppInheritanceChild)
        expect(child.instance_variable_get(:@dog)).to eq 'bark'
        expect(child.instance_variable_get(:@cat)).to eq 'meow'
      end

      it 'should fire the registered block on multiple inheritance' do
        child1 = Class.new(RackAppInheritanceChild)
        child2 = Class.new(child1)

        expect(child2.instance_variable_get(:@dog)).to eq 'bark'
        expect(child2.instance_variable_get(:@cat)).to eq 'meow'
      end

    end

  end
end