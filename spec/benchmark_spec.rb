require File.join(File.dirname(__FILE__), 'benchmark_spec', 'rack_app')
require File.join(File.dirname(__FILE__), 'benchmark_spec', 'rack_skeleton')

require 'spec_helper'
require 'benchmark'
require 'rack/app/test'

describe '#Performance Benchmark' do

  let(:test_amount) { (ENV['BENCHMARK_QUANTITY'] || 100).to_i }
  let(:rack_app_result) { Benchmark.measure { test_amount.times { ::Rack::MockRequest.new(RackApp).get(request_path) } } }
  let(:raw_rack_result) { Benchmark.measure { test_amount.times { ::Rack::MockRequest.new(RackSkeleton).get(request_path) } } }

  let(:maximum_accepted_seconds) do
    if RUBY_VERSION >= '1.9'
      5
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

end
