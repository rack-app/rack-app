class MountedApp < Rack::App
  cli do

    command :hello do

      description "hello world cli"
      action do |word|
        $stdout.puts "hello #{word}!"
      end

    end

  end
end

class App < Rack::App

  mount MountedApp

  get '/' do 
    'root'
  end 

end

App.cli  do

  command :test do

    description "it's a sample test cli command"

    option '-c', '--content [STRING]', 'add content to test file the following string' do |string|
      options[:append]= string
    end

    action do |file_path|
      options[:append] ||= 'default'

      $stdout.puts [file_path, options[:append]].join(' ')
    end

  end

end

class ExampleMiddleware
  def initialize(app)
    @custom = app
  end

  def call(env)
    @custom.call(env)
  end
end

use ExampleMiddleware

run App
