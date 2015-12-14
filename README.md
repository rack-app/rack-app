# Rack::Appi [![Build Status][travis-image]][travis-link]

[travis-image]: https://secure.travis-ci.org/adamluzsi/rack-app.rb.png?branch=master
[travis-link]: http://travis-ci.org/adamluzsi/rack-app.rb
[travis-home]: http://travis-ci.org/

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

class YourAwesomeApp < Rack::App

  get '/hello' do
    'Hello World!'
  end

  get '/users/:user_id' do 
    get_user_id 
  end 
  
  def get_user_id
    params['user_id']
  end 
  
end

run YourAwesomeApp

```

you can access Rack::Request with the request method and 
Rack::Response as response method. 

By default if you dont write anything to the response 'body' the endpoint block logic return will be used

## Testing 

use bundled in testing module for writing unit test for your rack application

```ruby

require 'spec_helper'
require 'rack/app/test'

describe MyRackApp do

  include Rack::App::Test
  
  rack_app described_class
  
  describe '#something' do
  
    subject{ get('/hello', params: {'dog' => 'meat'}, headers: {'X-Cat' => 'fur'}) }

    it { expect(subject.body).to eq ['world']}
    
    it { expect(subject.status).to eq 201 }
    
  end 
  
end 

```

## Example Apps To start with

* [Basic](https://github.com/adamluzsi/rack-app.rb-examples/tree/master/basic)
  * bare bone simple example app 
  
* [Escher Authorized Api](https://github.com/adamluzsi/rack-app.rb-examples/tree/master/escher_authorized)
  * complex authorization for corporal level api use

## [Benchmarking](https://github.com/adamluzsi/rack-app.rb-benchmark)

* Dumb duration with zero if or routing: 5.0e-06 s - 6.0e-06 s
  * no routing
  * return only a static array with static values
* Rack::App duration with routing lookup: 6.3e-05 s - 7.0e-05 s
  * with routing 
  * with value parsing and reponse object building
* Grape::API duration with routing lookup: 0.028236 s - 0.180764 s
  * with routing 
  * with value parsing and reponse object building
  
This was measured with multiple endpoints like that would be in real life example.
i feared do this for Rails that is usually slower than Grape :S

## Roadmap 

### 0.10.0

* serializer block/method for class shared serialization logic
* Mount method should able to take namespace option
* Create erb Parser Gem for View/FileServer to support to .erb files

### 0.11.0

* content_type syntax sugar on class level 
* response_headers syntax sugar for request processing 

### 0.12.0

* custom error_handler block for api, where Exception class types can be defined to process
  * NULL Object pattern for error_handler_fetcher

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/adamluzsi/rack-app.rb This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

