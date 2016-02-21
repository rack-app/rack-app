require File.join(File.dirname(__FILE__), 'benchmark_spec', 'rack_app')
require File.join(File.dirname(__FILE__), 'benchmark_spec', 'rack_skeleton')

require 'spec_helper'
require 'benchmark'

require 'rack/app/test'

describe '#Performance Benchmark' do

  include Rack::App::Test

  let(:test_amount) { 10000 }
  let(:rack_app_result) { Benchmark.measure { test_amount.times { RackApp.call(request_env_by('GET', request_path, {})) } } }
  let(:raw_rack_result) { Benchmark.measure { test_amount.times { RackSkeleton.call(request_env_by('GET', request_path, {})) } } }

  describe 'speed difference measured from empty rack class' do
    subject { rack_app_result.real / raw_rack_result.real }
    before{ puts(subject) } if ENV['VERBOSE'] =~ /^t/i

    context 'when static endpoint is requested' do
      let(:request_path) { '/' }

      it { is_expected.to be < 8 }
    end

    context 'when dynamic endpoint is requested' do
      let(:request_path) { '/users/123' }

      it { is_expected.to be < 8 }
    end

  end

end
