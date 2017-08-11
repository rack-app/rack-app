require 'spec_helper'
require 'time'

RSpec.describe Rack::App do
  include Rack::App::Test

  rack_app do
    validate_params do
      optional :date, :class => :date
      optional :time, :class => :time
      optional :date_time, :class => :datetime
    end
    get do
      Marshal.dump(params)
    end
  end

  describe '#params' do
    subject(:response) { get(:url => '/', :params => params) }
    let(:response_object) { Marshal.load(response.body) }
    let(:time_now) { Time.new(1990, 5, 2, 18, 3).utc }

    context 'when Date received in iso8601 format' do
      let(:today) { time_now.to_date }
      let(:params) { { :date => today.iso8601 } }

      it { expect(response_object).to eq 'date' => today }
    end

    context 'when Time received in iso8601 format' do
      let(:now) { time_now }
      let(:params) { { :time => now.iso8601 } }

      it { expect(response_object).to eq 'time' => now }
    end

    context 'when DateTime received in iso8601 format' do
      let(:now) { time_now.to_datetime }
      let(:params) { { :date_time => now.iso8601 } }

      it { expect(response_object).to eq 'date_time' => now }
    end
  end
end
