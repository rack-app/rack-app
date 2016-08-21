require "spec_helper"
describe Rack::App do
  include Rack::App::Test

  let(:env) do
    {Rack::App::Constants::ENV::SERIALIZER => Rack::App::Serializer.new}
  end

  def stream(options={},&back)
    Rack::App::Streamer.new(env, options, &back)
  end


  def assert(something, *_)
    expect(something).to be true
  end
  def assert_equal(expected,actualy)
    expect(expected).to eq actualy
  end
  def assert_raises(exception,&block)
    expect(&block).to raise_error(exception)
  end

  it 'returns the concatenated body' do
    rack_app do
      get('/') do
        stream do |out|
          out << "Hello" << " "
          out << "World!"
        end
      end
    end

    get('/')
    expect(last_response.body).to eq "Hello World!"
  end

  it 'always yields strings' do
    rack_app do
      get '/' do
        stream do |out|
          out << :foo
        end
      end
    end

    expect(get('/').body).to eq 'foo'
  end

  it 'postpones body generation' do
    step = 0

    stream = stream do |out|
      10.times do
        out << step
        step += 1
      end
    end

    stream.each do |s|
      assert_equal s, step.to_s
      step += 1
    end
  end

  it 'calls the callback after it is done' do
    step   = 0
    final  = 0
    stream = stream { |_| 10.times { step += 1 }}
    stream.callback { final = step }
    stream.each {|_|}
    assert_equal 10, final
  end

  it 'does not trigger the callback if close is set to :keep_open' do
    step   = 0
    final  = 0
    stream = stream(:keep_open => true) { |_| 10.times { step += 1 } }
    stream.callback { final = step }
    stream.each {|_|}
    assert_equal 0, final
  end

  it 'allows adding more than one callback' do
    a = b = false
    stream = stream { }
    stream.callback { a = true }
    stream.callback { b = true }
    stream.each {|_| }
    assert a, 'should trigger first callback'
    assert b, 'should trigger second callback'
  end

  class MockScheduler
    def initialize(*)     @schedule, @defer = [], []                end
    def schedule(&block)  @schedule << block                        end
    def defer(&block)     @defer    << block                        end
    def schedule!(*)      @schedule.pop.call until @schedule.empty? end
    def defer!(*)         @defer.pop.call    until @defer.empty?    end
  end

  it 'allows dropping in another scheduler' do
    scheduler  = MockScheduler.new
    processing = sending = done = false

    stream = stream(:scheduler => scheduler) do |out|
      processing = true
      out << :foo
    end

    stream.each { sending = true}
    stream.callback { done = true }

    scheduler.schedule!
    assert !processing
    assert !sending
    assert !done

    scheduler.defer!
    assert processing
    assert !sending
    assert !done

    scheduler.schedule!
    assert sending
    assert done
  end

  it 'schedules exceptions to be raised on the main thread/event loop/...' do
    scheduler = MockScheduler.new
    stream(:scheduler => scheduler) { fail 'should be caught' }.each { }
    scheduler.defer!
    assert_raises(RuntimeError) { scheduler.schedule! }
  end

  it 'does not trigger an infinite loop if you call close in a callback' do
    stream = stream { |out| out.callback { out.close }}
    stream.each { |_| }
  end

  it 'gives access to route specific params' do
    rack_app do
      get('/:name') do
        stream { |o| o << params['name'] }
      end
    end
    get '/foo'
    expect(last_response.body).to eq 'foo'
  end

  it 'use the class defined serializer' do
    rack_app do
      require 'yaml'
      serializer{ |obj| YAML.dump(obj) }
      get('/:name') do
        stream do |o|
          obj = {:dog => 'bark'}
          o << obj
        end
      end
    end
    get '/foo'
    expect(YAML.load(last_response.body)).to eq :dog => 'bark'
  end

  it 'sets up async.close if available' do
    ran = false
    rack_app do
      get('/async_close') do
        close = Object.new
        def close.callback; yield end
        def close.errback; end
        request.env['async.close'] = close

        stream(:keep_open) do |out|
          out.callback { ran = true }
        end
      end
    end
    get '/async_close'

    assert ran
  end

  it 'sets up async.close if available even when middlewares included' do
    ran = false
    rack_app do

      headers 'Access-Control-Allow-Origin' => '*',
              'Access-Control-Expose-Headers' => 'X-My-Custom-Header, X-Another-Custom-Header',
              ::Rack::CONTENT_TYPE => 'application/json'

      get('/async_close') do
        close = Object.new
        def close.callback; yield end
        def close.errback; end
        request.env['async.close'] = close

        stream(:keep_open) do |out|
          out.callback { ran = true }
        end
      end
    end
    get '/async_close'

    assert ran
  end

  it 'has a public interface to inspect its open/closed state' do
    stream = stream { |out| out << :foo }
    assert !stream.closed?
    stream.close
    assert stream.closed?
  end
end
