require File.join(File.dirname(__FILE__), 'benchmark_spec', 'rack_app')
require File.join(File.dirname(__FILE__), 'benchmark_spec', 'rack_skeleton')

require 'spec_helper'
require 'benchmark'
require 'rack/app/test'
require 'timeout'

describe '#Performance Benchmark' do

  let(:test_amount) { (ENV['BENCHMARK_QUANTITY'] || 100).to_i }
  let(:rack_app_result) { Benchmark.measure { test_amount.times { ::Rack::MockRequest.new(RackApp).get(request_path) } } }
  let(:raw_rack_result) { Benchmark.measure { test_amount.times { ::Rack::MockRequest.new(RackSkeleton).get(request_path) } } }

  let(:maximum_accepted_seconds) do
    if RUBY_VERSION >= '1.9'
      6
    else
      13
    end
  end

  describe 'speed difference measured from empty rack class' do
    subject { rack_app_result.real / raw_rack_result.real }
    before { puts(subject) } if ENV['VERBOSE'] =~ /^t/i

    context 'when static endpoint is requested' do
      let(:request_path) { '/' }

      it { is_expected.to be < maximum_accepted_seconds }
    end

    context 'when dynamic endpoint is requested' do
      let(:request_path) { '/users/123' }

      it { is_expected.to be < maximum_accepted_seconds }
    end

  end

  describe 'route tree generation time' do
    include Rack::App::Test
    context 'when only static endpoints given' do
      rack_app Class.new(Rack::App)

      it 'should initialize the application in a meaningful time' do
        Timeout.timeout(10) do
          time_now = Time.now
          rack_app do
            10_000.times do |i|
              get "/#{i}" do
                'Hello, World!'
              end
            end
          end
          puts(Time.now - time_now) if ENV['VERBOSE'] =~ /^t/i
        end
      end
    end

    context 'when only dynamic endpoints given' do
      rack_app Class.new(Rack::App)

      it 'should initialize the application in a meaningful time' do
        Timeout.timeout(10) do
          time_now = Time.now
          rack_app do
            10_000.times do |i|
              get "/#{i}/:id" do
                'Hello, World!'
              end
            end
          end
          puts(Time.now - time_now) if ENV['VERBOSE'] =~ /^t/i
        end
      end
    end

  end

end
