# Souls

Welcome to SOULS Framework!

SOULS is a Web Application Framework for Microservices on Google Cloud Platform.

SOULS creates 3 types of framework.

1. Service - gRPC Serverless Scalable Service
2. API - GraphQL to call gRPC 
3. Client - TypeScript Framework

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'souls'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install souls

## Usage

### Create Your APP

    $ souls new app_name

### Choose SOULS Type:
1. Serivice
2. API
3. Client

### Run Local
1. Serivice
    $ souls s

2. API
    $ rails s

3. Client
    $ yarn dev

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elsoul/souls.

