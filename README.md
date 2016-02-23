# [Rack::App](http://rack-app.com/) [![Build Status][travis-image]][travis-link]

[travis-image]: https://travis-ci.org/rack-app/rack-app.svg?branch=master
[travis-link]: http://travis-ci.org/rack-app/rack-app
[travis-home]: http://travis-ci.org/

![Rack::App](http://rack-app-website.herokuapp.com/image/msruby_old.png)

Your next favourite rack based micro framework that is totally addition free! 
Have a cup of awesomeness with your performance designed framework!

The idea behind is simple.
Keep the dependencies and everything as little as possible,
while able to write pure rack apps,
that will do nothing more than what you defined.

If you want see fancy magic, you are in a bad place buddy!
This includes that it do not have such core extensions like activesupport that monkey patch the whole world.

Routing can handle any amount of endpoints that can fit in the memory,
so if you that crazy to use more than 10k endpoint,
you still dont have to worry about response speed.

It was inspirited by sinatra, grape, and the pure use form of rack.
It's in production, powering Back Ends on Heroku

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-app'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-app


## Is it Production ready?

Yes, in fact it's already powering heroku hosted micro-services.

## Principles

* Keep It Simple
* No Code bloat
* No on run time processing, or keep at the bare minimum
* Fully BDD (Behaviour Driven Design)
  * build in test module to ease the development with easy to use tests
* Easy to Learn
  * rack-app use well known and easy to understand conventions, such as sinatra like DSL
* Principle Of Least Surprise
* Modular design
* Only dependency is rack, nothing more
* Open development
* Try to create Examples for every feature so even the "sketch to learn new" types can feel in comfort

## Features

* easy to understand syntax 
  * module method level endpoint definition inspirited heavily by the Sinatra DSL
  * unified error handling
  * syntax sugar for default header definitions 
  * namespaces for endpoint request path declarations so it can be dry and unified
* no Class method bloat, so you can enjoy pure ruby without any surprises 
* App mounting so you can crete separated controllers for different task  
* Null time look up routing
  * allows as many endpoint registration to you as you want, without impact on route look up speed
* only basic sets for instance method lvl for the must need tools, such as params, payload
* simple to use class level response serializer 
  * so you can choose what type of serialization you want without any enforced convention
* static file serving so you can mount even filesystem based endpoints too
* built in testing module so your app can easily written with BDD approach
* made with performance in mind so your app don't lose time by your framework
* per endpoint middleware definitions
  * you can define middleware stack before endpoints and it will only applied to them, similar like protected method workflow

## Usage

config.ru

#### basic 

```ruby

require 'rack/app'

class App < Rack::App

  desc 'some hello endpoint'
  get '/hello' do
    'Hello World!'
  end

end

```

#### complex

```ruby

require 'rack/app'

class App < Rack::App

  mount SomeAppClass

  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Expose-Headers' => 'X-My-Custom-Header, X-Another-Custom-Header'

  serializer do |object|
    object.to_s
  end

  desc 'some hello endpoint'
  get '/hello' do
    return 'Hello World!'
  end

  namespace '/users' do 
  
    desc 'some restful endpoint'
    get '/:user_id' do
      response.status = 201
      params['user_id'] #=> restful parameter :user_id
      say #=> "hello world!"
    end
    
  end
   
  desc 'some endpoint that has error and will be rescued'
  get '/make_error' do
    raise(StandardError,'error block rescued')
  end


  def say
    "hello #{params['user_id']}!"
  end

  error StandardError, NoMethodError do |ex|
    {:error=>ex.message}
  end

  root '/hello'

end

```

you can access Rack::Request with the request method and 
Rack::Response as response method. 

By default if you dont write anything to the response 'body' the endpoint block logic return will be used

## Testing 

for testing use rack/test or the bundled testing module for writing unit test for your rack application

```ruby

require 'spec_helper'
require 'rack/app/test'

describe App do

  include Rack::App::Test

  rack_app described_class

  describe '/hello' do
    # example for params and headers and payload use
    subject{ get(url: '/hello', params: {'dog' => 'meat'}, headers: {'X-Cat' => 'fur'}, payload: 'some string') }

    it { expect(subject.status).to eq 200 }

    it { expect(subject.body.join).to eq "Hello World!" }
  end

  describe '/users/:user_id' do
    # restful endpoint example
    subject{ get(url: '/users/1234') }

    it { expect(subject.body.join).to eq 'hello 1234!'}

    it { expect(subject.status).to eq 201 }

  end

  describe '/make_error' do
    # error handled example
    subject{ get(url: '/make_error') }

    it { expect(subject.body.join).to eq '{:error=>"error block rescued"}' }
  end

end


```

## Example Apps To start with

* [Basic](https://github.com/rack-app/rack-app-example-basic)
  * bare bone simple example app 
  
* [Escher Authorized Api](https://github.com/rack-app/rack-app-example-escher)
  * complex authorization for corporal level api use

## [Benchmarking](https://github.com/adamluzsi/rack-app.rb-benchmark)

the benchmarking was taken on the following hardware specification:
* Processor: 2,7 GHz Intel Core i5
* Memory: 16 GB 1867 MHz DDR3
* Ruby: ruby 2.1.2p95 (2014-05-08 revision 45877) [x86_64-darwin15.0]
* Endpoint declaration count: 1000

| name                   | version                | current / fastest      | user                   | system                 | total                  | real                   |
| ---------------------- | ---------------------- | ---------------------- | ---------------------- | ---------------------- | ---------------------- | ---------------------- |
| rack                   | 1.6.4                  | 1.0                    | 4.4999999999994597e-10 | 4.999999999999855e-11  | 5.000000000001581e-10  | 4.669824999999623e-10  |
| rack-app               | 0.23.0                 | 5.64                   | 2.6249999999995462e-09 | 5.0000000000003155e-11 | 2.674999999999656e-09  | 2.6337825000000033e-09 |
| ramaze                 | 2012.12.08             | 10.761                 | 4.7250000000004294e-09 | 3.249999999997837e-10  | 5.0499999999999815e-09 | 5.025382500000196e-09  |
| brooklyn               | 0.0.1                  | 135.196                | 6.202499999997365e-08  | 2.5000000000010383e-10 | 6.227499999994257e-08  | 6.31342025000291e-08   |
| nancy                  | 0.3.0                  | 141.491                | 6.44500000000412e-08   | 4.0000000000002173e-10 | 6.485000000002128e-08  | 6.607404000000881e-08  |
| rails                  | 4.2.5.1                | 149.063                | 6.475000000004323e-08  | 2.54999999999825e-09   | 6.729999999999027e-08  | 6.960978250001378e-08  |
| hobbit                 | 0.6.1                  | 152.009                | 6.86499999999909e-08   | 5.50000000000627e-10   | 6.920000000002929e-08  | 7.09855800000375e-08   |
| scorched               | 0.25                   | 206.02                 | 9.227499999997586e-08  | 6.249999999997911e-10  | 9.289999999997338e-08  | 9.620763750005751e-08  |
| sinatra                | 1.4.7                  | 252.893                | 1.1582499999996941e-07 | 9.000000000006287e-10  | 1.167249999999214e-07  | 1.1809659249996387e-07 |
| grape                  | 0.14.0                 | 999.893                | 4.5052499999980065e-07 | 4.900000000001301e-09  | 4.554249999998522e-07  | 4.66932680000025e-07   |
| camping                | 2.1.532                | 2246.199               | 1.0080499999997654e-06 | 1.4049999999999699e-08 | 1.0220999999995006e-06 | 1.0489356725004438e-06 |
| cuba                   | 3.5.0                  | 2951.837               | 1.3101249999997173e-06 | 1.302499999999637e-08  | 1.3231499999997228e-06 | 1.3784562299989904e-06 |

## Roadmap 

### Team [Backlog](https://docs.google.com/spreadsheets/d/19GGX51i6uCQQz8pQ-lvsIxu43huKCX-eC1526-RL3YA/edit?usp=sharing)

If you have anything to say, you can leave a comment. :)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/adamluzsi/rack-app.rb This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

