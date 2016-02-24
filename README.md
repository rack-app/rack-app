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

## [Benchmarking](https://github.com/rack-app/rack-app-benchmark)

the benchmarking was taken on the following hardware specification:
* Processor: 2,7 GHz Intel Core i5
* Memory: 16 GB 1867 MHz DDR3
* Ruby: ruby 2.1.2p95 (2014-05-08 revision 45877) [x86_64-darwin15.0]

### number of declared endpoints: 100

| name                   | version                | current / fastest      | real                   |
| ---------------------- | ---------------------- | ---------------------- | ---------------------- |
| rack                   | 1.6.4                  | 1.0                    | 1.6755999999997824e-06 |
| rack-app               | 0.23.0                 | 12.949                 | 2.169760000000045e-05  |
| ramaze                 | 2012.12.08             | 23.622                 | 3.9581600000001146e-05 |
| hobbit                 | 0.6.1                  | 40.391                 | 6.76790000000015e-05   |
| brooklyn               | 0.0.1                  | 72.983                 | 0.00012229050000000643 |
| nancy                  | 0.3.0                  | 91.488                 | 0.00015329779999998726 |
| scorched               | 0.25                   | 179.476                | 0.00030072970000003256 |
| sinatra                | 1.4.7                  | 191.033                | 0.00032009470000000435 |
| rails                  | 4.2.5.1                | 453.927                | 0.0007605999000000241  |
| camping                | 2.1.532                | 574.146                | 0.0009620388000000196  |
| grape                  | 0.14.0                 | 582.409                | 0.000975884299999979   |
| cuba                   | 3.5.0                  | 763.772                | 0.001279777100000003   |

For more reports check the Benchmark repo out :)

## Roadmap 

### Team [Backlog](https://docs.google.com/spreadsheets/d/19GGX51i6uCQQz8pQ-lvsIxu43huKCX-eC1526-RL3YA/edit?usp=sharing)

If you have anything to say, you can leave a comment. :)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/adamluzsi/rack-app.rb This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License and Copyright
   
Rack::App is free software released under the [Apache License V2](https://opensource.org/licenses/Apache-2.0) License.
The logo was designed by Zsófia Gebauer. It is Copyright © 2015 Adam Luzsi. All Rights Reserved.