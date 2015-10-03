# Rack::App

Super bare bone Rack::App for writing minimalist/masochist rack apps

The idea behind is simple. 
Have a little framework that can allow you write pure rack apps,
that will do nothing more than what you defined.

This includes that it do not depend on fat libs like activesupport. 
 
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

class YourAwesomeApp < Rack::APP

  get '/hello' do
    'Hello World!'
  end

  get '/nope' do
    request.env
    response.write 'some response body'
    
  end
  
  post '/lol_post' do 
    status 500 
    'LOL'
  end

end

run YourAwesomeApp
```

## TODO

* benchmark for rails, padrino, sinatra, grape etc to prove awesomeness
* more verbose readme
* drink less coffee
* support restful endpoints
  * params
  * route-matching

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rack-app. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

