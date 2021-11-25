[![SOULs](https://souls.elsoul.nl/ogp.jpg)](https://souls.elsoul.nl)

<p align="center">
  <a aria-label="Ruby logo" href="https://el-soul.com">
    <img src="https://badgen.net/badge/icon/Made%20by%20ELSOUL?icon=ruby&label&color=black&labelColor=black">
  </a>
  <a href="https://twitter.com/intent/follow?screen_name=SOULsOpenSource">
    <img src="https://img.shields.io/twitter/follow/SOULsOpenSource.svg?label=Follow%20@SOULsOpenSource" alt="Follow @SOULsOpenSource" />
  </a>
  <br/>

  <a aria-label="Ruby Gem version" href="https://rubygems.org/gems/souls">
    <img alt="" src="https://badgen.net/rubygems/v/souls/latest">
  </a>
  <a aria-label="Downloads Number" href="https://rubygems.org/gems/souls">
    <img alt="" src="https://badgen.net/rubygems/dt/souls">
  </a>
   <a aria-label="Test" href="https://rubygems.org/gems/souls">
    <img alt="" src="https://github.com/elsoul/souls/actions/workflows/test.yml/badge.svg">
  </a>
  <a aria-label="License" href="https://github.com/elsoul/souls/blob/master/LICENSE.txt">
    <img alt="" src="https://badgen.net/badge/license/Apache/blue">
  </a>
    <a aria-label="Code of Conduct" href="https://github.com/elsoul/souls/blob/master/code_of_conduct.md">
    <img alt="" src="https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg">
  </a>
</p>


## Ruby Serverless Application Framework SOULs Document

- [Go to SOULs Document](https://souls.elsoul.nl/)

<p>
  <a aria-label="Ruby Serverless Application Framework SOULs Document" href="https://souls.elsoul.nl/">
    <img src="https://souls.elsoul.nl/imgs/gifs/souls-new-video.gif">
  </a>
</p>

## What's SOULs?

Ruby Serverless Framework 'SOULs'. 

The SOULs project was launched with the goal of reducing software development, operation and maintenance costs. 

Build Serverless Apps faster like Rails.
Powered by Ruby GraphQL, RBS/Steep, Active Record, RSpec, RuboCop, and Google Cloud. 

- Focus on business logic in serverless environment
- Maximize development efficiency with CI / CD standard schema-driven Scaffold
- Achieve global scale with lower management costs

![SOULs Architecture](https://souls.elsoul.nl/imgs/docs/SOULs-architecture.jpg)

SOULs creates 2 types of APP.

1. API - GraphQL (Ruby) - Simple API - Cloud Run
2. Worker - Google Pub/Sub Messaging Worker API (Ruby) - Cloud Run

## Ruby type checking
The SOULs framework uses RBS / Steep, which appeared in Ruby 3.0.

- [RBS](https://github.com/ruby/rbs/)
- [Steep](https://github.com/soutaro/steep/)

As a result, typos, column types, etc.

It is a development environment where you can immediately notice the mistakes that occur frequently.

<p>
  <a aria-label="RBS Demo" href="https://souls.elsoul.nl/ja/docs/guides/basic/type-check/">
    <img src="https://souls.elsoul.nl/imgs/gifs/rbs-video.gif">
  </a>
</p>


## Dependency

- [Google SDK](https://cloud.google.com/sdk/docs)
- [Docker](https://www.docker.com/)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Ruby](https://www.ruby-lang.org)
- [Github CLI](https://cli.github.com/)

## Cloud Infrastructure

- [Google Cloud Run](https://cloud.google.com/run)
- [Google Cloud SQL](https://cloud.google.com/sql)
- [Google Cloud Pub/Sub](https://cloud.google.com/pubsub)
- [Google Cloud Storage](https://cloud.google.com/run)
- [Google Cloud IAM](https://cloud.google.com/iam)
- [Google Cloud Container Registry](https://cloud.google.com/container-registry)
- [Google Firebase](https://firebase.google.com/)
- [Google Cloud Scheduler](https://cloud.google.com/scheduler)
- [Google Cloud VPC](https://cloud.google.com/vpc)
- [Google Cloud Nat](https://cloud.google.com/nat)
- [Github Actions](https://github.com/features/actions)

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
    $ cd apps/api/app_name
    $ souls s

Check your GraphQL PlayGround

[localhost:4000/playground](localhost:4000/playground)



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `souls t` to run the tests. You can also run `souls c` for an interactive prompt that will allow you to experiment.

You need to add submodule

```bash
git submodule add -f https://github.com/ruby/gem_rbs_collection.git vendor/rbs/gem_rbs_collection
```

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org/gems/souls).

## Test Coverage

[Rspec Test Coverage](https://storage.googleapis.com/souls-bucket/souls-coverage/index.html#_AllFiles)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elsoul/souls. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [Apache-2.0 License](https://www.apache.org/licenses/LICENSE-2.0).

## Code of Conduct

Everyone interacting in the HotelPrice project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/elsoul/souls/blob/master/CODE_OF_CONDUCT.md).
