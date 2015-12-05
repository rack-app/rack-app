require 'spec_helper'

describe Rack::App::View do
  context 'given the call method is defined in the inherited class' do

    let(:instance) do
      o = described_class.new
      o.define_singleton_method(:call) { |r| 'nope' }
      o
    end

    describe '#class_current_folder' do
      subject { instance.class_current_folder }

      it { is_expected.to eq __FILE__.to_s.sub(/.rb$/, '') }
    end

    describe '#render' do
      subject{ instance.render('index.html.erb') }

      it { is_expected.to eq 'hello world!' }
    end

  end
end