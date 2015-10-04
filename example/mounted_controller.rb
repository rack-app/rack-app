class MountedController < Rack::APP

  get '/first' do
    first
  end

  def first
    'some text'
  end

end