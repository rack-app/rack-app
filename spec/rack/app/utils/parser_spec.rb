require "spec_helper"
describe Rack::App::Utils::Parser do

  describe '.parse' do
    subject{ described_class.parse(type, str) }

    [:string, ::String].each do |params_type|
      context "when #{params_type} type" do
        let(:str){'Hello world'}
        let(:type){ params_type }
        it { is_expected.to eq str }
      end
    end

    [:boolean, ::TrueClass, ::FalseClass].each do |params_type|
      context "when #{params_type} type" do
        let(:type){ params_type }

        context 'and str is a valid true' do
          let(:str){'true'}

          it { is_expected.to be true }
        end

        context 'and str is a valid false' do
          let(:str){'false'}

          it { is_expected.to be false }
        end

        context 'and str is an invalid boolean' do
          let(:str){'hello world'}

          it { is_expected.to be nil }
        end

      end
    end

    [:date, ::Date].each do |params_type|
      context "when #{params_type} type" do
        let(:type){ params_type }

        context 'and str is a valid date' do
          let(:str){"2016-07-24"}

          it { is_expected.to eq Date.new(2016,7,24) }
        end

        context 'and str is an invalid date' do
          let(:str){'hello world'}

          it { is_expected.to be nil }
        end

      end

      context 'when Time type' do
        let(:type){ :time }

        context 'and str is a valid time' do
          let(:str){"2016-07-25T00:23:39+02:00"}

          it { is_expected.to eq Time.new(2016,7,25,0,23,39,"+02:00") }
        end

        context 'and str is an invalid time' do
          let(:str){'hello world'}

          it { is_expected.to be nil }
        end

      end
    end

    [:datetime, :date_time, ::DateTime].each do |params_type|
      context "when #{params_type} type" do
        let(:type){ params_type }

        context 'and str is a valid datetime' do
          let(:str){"2016-07-25T00:23:39+02:00"}

          it { is_expected.to eq DateTime.new(2016,7,25,0,23,39,"+02:00") }
        end

        context 'and str is an invalid datetime' do
          let(:str){'hello world'}

          it { is_expected.to be nil }
        end
      end
    end

    [:float, ::Float].each do |params_type|
      context "when #{params_type} type" do
        let(:type){ params_type }

        context 'and str is a valid float' do
        let(:str){"1.1"}

          it { is_expected.to eq 1.1 }
        end

        context 'and str is an invalid float' do
          let(:str){'10'}

          it { is_expected.to be nil }
        end

      end
    end

    [:integer, ::Integer].each do |params_type|
      context "when #{params_type} type" do
        let(:type){ params_type }

        context 'and str is a valid integer' do
          let(:str){"10"}

          it { is_expected.to eq 10 }
        end

        context 'and str is an invalid integer' do
          let(:str){'1.0'}

          it { is_expected.to be nil }
        end

      end
    end

    [:numeric,::Numeric].each do |params_type|
      context "when #{params_type} type" do
        let(:type){ params_type }

        context 'and str is a valid numeric(int)' do
          let(:str){"10"}

          it { is_expected.to eq 10 }
        end

        context 'and str is a valid numeric' do
          let(:str){"10"}

          it { is_expected.to eq 10 }
        end

        context 'and str is an invalid numeric' do
          let(:str){'hello'}

          it { is_expected.to be nil }
        end

      end
    end

  end
end
