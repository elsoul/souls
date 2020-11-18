# SOULs

Welcome to SOULs Framework!

SOULs is a Web Application Framework for Microservices on Google Cloud Platform.

<p align="center">

  <a aria-label="Ruby logo" href="https://el-soul.com">
    <img src="https://badgen.net/badge/icon/Made%20by%20ELSOUL?icon=ruby&label&color=black&labelColor=black">
  </a>
  <br/>

  <a aria-label="Ruby Gem version" href="https://rubygems.org/gems/souls">
    <img alt="" src="https://badgen.net/rubygems/v/souls/latest">
  </a>
  <a aria-label="Downloads Number" href="https://rubygems.org/gems/souls">
    <img alt="" src="https://badgen.net/rubygems/dt/souls">
  </a>
  <a aria-label="License" href="https://github.com/elsoul/souls/blob/master/LICENSE">
    <img alt="" src="https://badgen.net/badge/license/Apache/blue">
  </a>
</p>

## Dependency

1. Google SDK
   [https://cloud.google.com/sdk/docs](https://cloud.google.com/sdk/docs)
2. Docker
   [https://www.docker.com/](https://www.docker.com/)

Using:

☆Google Kubernates Engine

☆Google Traffic Director

☆Google Cloud Run

☆Google Firebase


SOULS creates 4 types of framework.

1. Service - gRPC Serverless Scalable Service
2. API - GraphQL to call gRPC 
3. Media Web Client - Medeia Auto Analiytics
4. Admin Web Client - Admin Console Panel

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'souls'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install souls


And Create Your APP

    $ souls new app_name

### Choose SOULs Type:
1. Service
2. API
3. Media Web
4. Admin Web

### Usage
Init Proto Files

    $ souls p `service_name`


Run Server

    $ souls s

Run Console

    $ souls c

Run Infra Command

    $ souls i `method_name`


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org/gems/souls).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elsoul/souls. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [Apache-2.0 License](https://www.apache.org/licenses/LICENSE-2.0).

## Code of Conduct

Everyone interacting in the HotelPrice project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/elsoul/souls/blob/master/CODE_OF_CONDUCT.md).
