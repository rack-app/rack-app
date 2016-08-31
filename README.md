# [Rack::App](http://rack-app.com/) [![Build Status][travis-image]][travis-link]

[travis-image]: https://travis-ci.org/rack-app/rack-app.svg?branch=master
[travis-link]: http://travis-ci.org/rack-app/rack-app
[travis-home]: http://travis-ci.org/

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
* Streaming
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
* File Upload and file download in a efficient and elegant way with minimal memory consuming
  * note that this is not only memory friendly way pure rack solution, but also 2x faster than the usualy solution which includes buffering in memory
* params validation with ease

## [Contributors](CONTRIBUTORS.md)

## [Contributing](CONTRIBUTING.md)

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

  apply_extensions :front_end  

  mount SomeAppClass

  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Expose-Headers' => 'X-My-Custom-Header, X-Another-Custom-Header'

  serializer do |object|
    object.to_s
  end

  desc 'some hello endpoint'
  validate_params do
    required 'words', :class => Array, :of => String, :desc => 'some word', :example => ['pug']
    optional 'word', :class => String, :desc => 'one word', :example => 'pug'
  end
  get '/hello' do
    puts(validate_params['words'])

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

  get '/stream' do
    stream do |out|
      out << 'data row'
    end
  end

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

* [Official website How To examples](http://rack-app.com/)

* [Rack::App Team Github repositories](https://github.com/rack-app)

* [Basic](https://github.com/rack-app/rack-app-example-basic)
  * bare bone simple example app

* [Escher Authorized Api](https://github.com/rack-app/rack-app-example-escher)
  * complex authorization for corporal level api use

## [Benchmarking](https://github.com/rack-app/rack-app-benchmark)

This is a repo that used for measure Rack::App project speed in order keep an eye on the performance in every release.

the benchmarking was taken on the following hardware specification:
* Processor: 2,7 GHz Intel Core i5
* Memory: 16 GB 1867 MHz DDR3
* Ruby: ruby 2.3.0p0 (2015-12-25 revision 53290) [x86_64-darwin15]


### Endpoint to be call type: static


#### number of declared endpoints: 100

| name                   | version                | current / fastest      | real                   |
| ---------------------- | ---------------------- | ---------------------- | ---------------------- |
| rack-app               | 4.0.0                  | 1.0                    | 2.2053215187043942e-05 |
| rack-app               | 5.2.0                  | 1.185                  | 2.6140331494390213e-05 |
| rack-app               | 5.0.0.rc3              | 1.387                  | 3.0592694940592784e-05 |
| ramaze                 | 2012.12.08             | 1.468                  | 3.236885466806858e-05  |
| hobbit                 | 0.6.1                  | 2.996                  | 6.607205038890137e-05  |
| brooklyn               | 0.0.1                  | 5.243                  | 0.00011562206838279088 |
| nyny                   | 3.4.3                  | 5.272                  | 0.00011626420279498706 |
| plezi                  | 0.14.1                 | 5.334                  | 0.00011763589749898317 |
| nancy                  | 0.3.0                  | 5.649                  | 0.00012458588462322884 |
| roda                   | 2.17.0                 | 10.646                 | 0.00023477471132838754 |
| scorched               | 0.25                   | 12.728                 | 0.0002807019599946191  |
| sinatra                | 1.4.7                  | 21.169                 | 0.0004668393424013356  |
| grape                  | 0.17.0                 | 25.941                 | 0.0005720832234016178  |
| rails                  | 5.0.0                  | 33.234                 | 0.0007329187002032537  |
| camping                | 2.1.532                | 39.699                 | 0.0008754866444039887  |
| cuba                   | 3.8.0                  | 54.196                 | 0.001195195165998367   |
| almost-sinatra         | unknown                | 58.613                 | 0.0012926107780076503  |


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
