require "spec_helper"
describe Rack::App do
  include Rack::App::Test

  describe '.before' do
    rack_app do

      before { respond_with("breaked") if params["break_in_before"] }
      before { @say = 'Hello' }
      before { @word = 'World' }

      get '/say' do
        "#{@say}, #{@word}!"
      end

    end

    it { expect(get('/say').body).to eq 'Hello, World!' }

    it { expect(get('/say', :params => {"break_in_before" => true}).body).to eq 'breaked' }

  end

end
