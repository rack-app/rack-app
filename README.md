# Rack::APP

Your next favourite rack based micro framework that is totally addition free! 
Have a cup of awesomeness with  your performance designed framework!

The idea behind is simple. 
Keep the dependencies and everything as little as possible,
while able to write pure rack apps,
that will do nothing more than what you defined.

If you want see fancy magic, you are in a bad place buddy!
This includes that it do not have such core extensions like activesupport that monkey patch the whole world.

Routing can handle large amount of endpoints so if you that crazy to use more than 10k endpoint,
you still dont have to worry about response speed.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-app'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-app

## Usage

config.ru
```ruby

require 'rack/app'

require_relative 'lib/bootstrap'

class YourAwesomeApp < Rack::APP

  mount AwesomeController

  get '/hello' do
    'Hello World!'
  end

  get '/nope' do
    request.env
    response.write 'some response body'
  end
  
  post '/lol_post_fail' do 
    status 500 
    'LOL'
  end
  
  get '/users/:user_id' do 
    params['user_id']
  end 
  
  post '/some/endpoint/for/the/rabbit/:queue_name' do 
    mq_request # helper are the class instance method 
  end 
  
  def mq_request
    q = BUNNY_CONN_CHANNEL.queue(params['queue_name'])
    BUNNY_CONN_CHANNEL.default_exchange.publish(request.body.read, :routing_key => q.name)
  end 
  
end

run YourAwesomeApp
```

you can access Rack::Request with the request method and 
Rack::Response as response method. 

By default if you dont write anything to the response 'body' the endpoint block logic return will be used

## Example Apps To start with

* [Basic](https://github.com/adamluzsi/rack-app.rb-examples/tree/master/basic)
  * bare bone simple example app 
  
* [Escher Authorized Api](https://github.com/adamluzsi/rack-app.rb-examples/tree/master/escher_authorized)
  * complex authorization for corporal level api use

## [Benchmarking](https://github.com/adamluzsi/rack-app.rb-benchmark)

* Dump duration with zero if or routing: 6.0e-06 s
  * no routing
  * return only a static array with static values
* Rack::APP duration with routing lookup: 7.0e-05 s
  * with routing 
  * with value parsing and reponse object building
* Grape::API duration with routing lookup: 0.180764 s
  * with routing 
  * with value parsing and reponse object building
  
This was measured with multiple endpoints like that would be in real life example.
i feared do this for Rails that is usually slower than Grape :S

## TODO

* benchmark for Rails::API, Grape::API and etc to prove awesomeness in term of speed
* more verbose readme
* drink less coffee

## Roadmap 

### 0.3.0

* add TESTING module for rspec helpers that allow easy to test controllers

### 0.4.0

* serializer block/method for class shared serialization logic

### 0.5.0

* content_type syntax sugar on class level 
* response_headers syntax sugar for request processing 

### 0.6.0

* custom error_handler block for api, where Exception class types can be defined to process
  * NULL Object pattern for error_handler_fetcher

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/adamluzsi/rack-app.rb This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

