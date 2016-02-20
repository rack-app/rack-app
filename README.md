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

| name             |      user                  | system                 | total                 | real                   |
|------------------|----------------------------|------------------------|-----------------------|------------------------|
| rack             |      3.150000000000001e-05 | 1.3000000000000003e-06 | 3.280000000000001e-05 | 3.602101e-05           |
| rack-app         |      0.0005159999999999999 | 1.4000000000000005e-05 | 0.0005300000000000001 | 0.0005141295           |
| ramaze           |      0.0005166999999999999 | 1.98e-05               | 0.0005365             | 0.0005347348           |
| brooklyn         |      0.0007564             | 3.700000000000001e-06  | 0.0007601000000000001 | 0.0007743060099999998  |
| nancy            |      0.000812              | 5.900000000000001e-06  | 0.0008179000000000001 | 0.0008314749300000001  |
| scorched         |      0.0008451000000000001 | 4.699999999999999e-06  | 0.0008498000000000001 | 0.00085131501          |
| sinatra          |      0.0008465000000000001 | 7.000000000000001e-06  | 0.0008535000000000001 | 0.00086448211          |
| hobbit           |      0.0013664             | 4.5e-06                | 0.0013709             | 0.0013804752700000004  |
| grape            |      0.0018807             | 2.7800000000000005e-05 | 0.0019085             | 0.0019229531400000001  |
| rails            |      0.0018995000000000001 | 7.06e-05               | 0.0019701             | 0.00198401458          |
| camping          |      0.002921              | 7.24e-05               | 0.0029934000000000002 | 0.0030896778800000003  |
| cuba             |      0.0034559000000000005 | 2.8600000000000004e-05 | 0.0034845             | 0.00349655002          |

## Roadmap 

### Team [Backlog](https://docs.google.com/spreadsheets/d/19GGX51i6uCQQz8pQ-lvsIxu43huKCX-eC1526-RL3YA/edit?usp=sharing)

If you have anything to say, you can leave a comment. :)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/adamluzsi/rack-app.rb This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

