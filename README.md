# [Rack::App](http://www.rack-app.com/) [![Build Status][travis-image]][travis-link]

[travis-image]: https://travis-ci.org/rack-app/rack-app.svg?branch=master
[travis-link]: https://travis-ci.org/rack-app/rack-app
[travis-home]: http://travis-ci.org/

![rack-app-logo](/assets/rack-app-logo.png)

`rack-app` is a minimalist web framework that focuses on simplicity and maintainability.
The framework is meant to be used by seasoned web developers.

`rack-app` focus on keeping the dependencies as little as possible,
while allowing writing functional and minimalist rack-based applications,
that will do nothing more than what you defined.

The routing uses a prefix tree,
thus adding a large number of API endpoints won't affect the routing lookup time.

It was inspirited by `Sinatra`, `grape`, and `rack`.
It's used in production, powering back-end APIs running on the public cloud.

## Development Status

The framework is considered stable.
I don't have the plan to feature creep the framework without real-life use-cases,
since most of the custom edge cases can be resolved with composition.

The next time it will receive further updates,
when rack provides a finalized support for http2.

If you have an issue, I weekly check the issues tab,
answer and reply, or implement a fix for it.

Since the framework's only dependency is the `rack` gem,
I don't have to update the codebase too often.

Cheers and Happy Coding!

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

Yes, it's already powering Heroku hosted micro-services.

## Principles

* Keep It Simple
* No Code bloat
* No on run time processing, or keep at the bare minimum
* Fully BDD (Behaviour Driven Design)
  * built-in test module to ease the development with easy to use tests
* Easy to Learn
  * rack-app use well known and easy to understand conventions, such as sinatra like DSL
* Principle Of Least Surprise
* Modular design
* the Only dependency is rack, nothing more
* Open development
* Try to create Examples for every feature

## Features

* Easy to understand syntax
  * module method level endpoint definition inspirited heavily by the Sinatra DSL
  * unified error handling
  * syntax sugar for default header definitions
  * namespaces for endpoint request path declarations so it can be dry and unified
* no Class method bloat, so you can enjoy pure ruby without any surprises
* App mounting so you can create separated controllers for different task
* Streaming
* O(log(n)) lookup routing
  * allows as many endpoint registrations to you as you want, without impact on route lookup speed
* only basic sets for instance method level for the must need tools, such as params, payload
* Simple to use class level response serializer
  * so you can choose what type of serialization you want without any enforced convention
* static file serving so you can mount even filesystem-based endpoints too
* built-in testing module so your app can be easily written with BDD approach
* made with minimalism in mind so your app can't rely on the framework when you implement business logic
  * if you need something, you should implement it without any dependency on a web framework, rack-app only mean to be to provide you with easy to use interface to the web layer, nothing less and nothing more
* per endpoint middleware definitions
  * you can define middleware stack before endpoints and it will only apply to them, similar like protected method workflow
* File Upload and file download efficiently and elegantly with minimal memory consuming
  * note that this is not only memory friendly way pure rack solution, but also 2x faster than the usual solution which includes buffering in memory
* params validation with ease

## Under the hood

rack-app's router relies on a tree structure which makes heavy use of *common prefixes*,
it is basically a *compact* [*prefix tree*](https://en.wikipedia.org/wiki/Trie) (or just [*Radix tree*](https://en.wikipedia.org/wiki/Radix_tree)).
Nodes with a common prefix also share a common parent.

## Contributors

* **[Daniel Nagy](https://github.com/thilonel)**

  * Serializer MVP implementation

* **[Daniel Szpisjak](https://github.com/felin-arch)**

  * Pimp up the website descriptions

* **[Jeremy Evans](https://github.com/jeremyevans)**

  * suggestion for application stand up speed optimization

* **[David Bush](https://github.com/disavowd)**

  * [wrote an awesome article](https://www.sitepoint.com/rack-app-a-performant-and-pragmatic-web-microframework/) about the project

* **[TheSmartnik](https://github.com/TheSmartnik)**

  * Clarify examples in the documentation

## [Contributing](CONTRIBUTING.md)

## Usage

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
  validate_params do
    required 'words', :class => Array, :of => String, :desc => 'some word', :example => ['pug']
    optional 'word', :class => String, :desc => 'one word', :example => 'pug'
    optional 'boolean', :class => :boolean, :desc => 'boolean value', :example => true
  end
  get '/hello' do
    puts(params['words'])

    'Hello World!'
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
Rack::Response as a response method.

By default, if you don't write anything to the response 'body' the endpoint block logic return will be used

### Frontend Example

if you don't mind extending your dependency list then you can use the front_end extension for creating template-based web applications.

```ruby
require 'rack/app'
require 'rack/app/front_end' # You need to add `gem 'rack-app-front_end'` to your Gemfile

class App < Rack::App

  apply_extensions :front_end

  helpers do

    def method_that_can_be_used_in_template
      'hello world!'
    end

  end

  # use ./app/layout.html.erb as layout, this is optionable
  layout 'layout.html.erb'

  # at '/' the endpoint will serve (render)
  # the ./app/index.html content as response body and wrap around with layout if the layout is given
  get '/' do
    render 'index.html'
  end

end
```

this example expects an "app" folder next to the "app.rb" file that included templates being used such as layout.html.erb and index.html.

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
    subject { get(url: '/hello', params: {'dog' => 'meat'}, headers: {'X-Cat' => 'fur'}, payload: 'some string') }

    it { expect(subject.status).to eq 200 }

    it { expect(subject.body).to eq "Hello World!" }
  end

  describe '/users/:user_id' do
    # restful endpoint example
    subject { get(url: '/users/1234') }

    it { expect(subject.body).to eq 'hello 1234!'}

    it { expect(subject.status).to eq 201 }

  end

  describe '/make_error' do
    # error handled example
    subject { get(url: '/make_error') }

    it { expect(subject.body).to eq '{:error=>"error block rescued"}' }
  end

end


```

## Example Apps To start with

* [Official website How To examples](http://www.rack-app.com/)

* [Rack::App Team Github repositories](https://github.com/rack-app)

* [Basic](https://github.com/rack-app/rack-app-example-basic)
  * bare-bone simple example app

* [Escher Authorized Api](https://github.com/rack-app/rack-app-example-escher)
  * complex authorization for corporal level API use


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rack-app/rack-app This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License and Copyright

Rack::App is free software released under the [Apache License V2](https://opensource.org/licenses/Apache-2.0) License.
The logo was designed by Zsófia Gebauer. It is Copyright © 2015 Adam Luzsi. All Rights Reserved.
