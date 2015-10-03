class FirstController < Rack::API

  get '/first' do
    first
  end

  def first
    'some text'
  end

end