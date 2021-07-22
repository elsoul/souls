[![SOULs](https://storage.googleapis.com/souls/souls-ogp-vertical.jpg)](https://rubygems.org/gems/souls)

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

## What's SOULs?

Welcome to SOULs Serverless Application Framework!

SOULs is a Serverless Application Framework with GraphQL. 
SOULs has six strains, API, Worker, Console, Admin, Media, Doc, and can be used in combination according to the purpose. SOULs Backend GraphQL Ruby & Frontend Relay are Scalable and Easy to deploy to Google Cloud. No more routing for Backends!
You can focus on your business logic. No more infra problems.

SOULs creates 6 types of framework.

1. API - GraphQL (Ruby) - Simple API - Cloud Run
2. Worker - Google Pub/Sub Worker API (Ruby) - Cloud Run
3. Console Web Client - User Console and CMS (TypeScript)
4. Admin Web Client - Admin Console and CMS (TypeScript)
5. Media Web Client - Media web client with SSG (TypeScript)
6. Doc Web Client - Doc web client with SSG (TypeScript)

## Dependency

- [Google SDK](https://cloud.google.com/sdk/docs)
- [Docker](https://www.docker.com/)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Ruby](https://www.ruby-lang.org)

## Cloud Infrastructure

- [Google Cloud Run](https://cloud.google.com/run)
- [Google Cloud SQL](https://cloud.google.com/sql)
- [Google Cloud Pub/Sub](https://cloud.google.com/pubsub)
- [Google Cloud Storage](https://cloud.google.com/run)
- [Google Cloud IAM](https://cloud.google.com/iam)
- [Google Cloud DNS](https://cloud.google.com/dns)
- [Google Cloud Container Registry](https://cloud.google.com/container-registry)
- [Google Firebase](https://firebase.google.com/)
- [Google Cloud Scheduler](https://cloud.google.com/scheduler)
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

## Choose SOULs Type:

Select Strain:
1. SOULs GraphQL API
2. SOULs Worker
3. SOULs Console Web
4. SOULs Admin Web
5. SOULs Media Web
6. SOULs Doc Web


## Gemfile 自動更新アップデート

`Gemfile`, `Gemfile.lock` を最新のバージョンに自動更新します。

```
souls gem:update
```


除外したい `gem` は `config/souls.rb` 内の
`config.fixed_gems` の配列に追加します。


```ruby
Souls.configure do |config|
  config.app = "souls-api"
  config.project_id = "souls-api"
  config.strain = "api"
  config.worker_endpoint = "https://worker.com"
  config.fixed_gems = ["selenium-webdriver", "pg"]
end
```



## SOULs Serverless Application Framework Document

SOULs サーバーレスアプリケーションフレームワーク
ドキュメントはこちらから
- [SOULs Document](https://souls.elsoul.nl/)



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `souls t` to run the tests. You can also run `souls c` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org/gems/souls).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elsoul/souls. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [Apache-2.0 License](https://www.apache.org/licenses/LICENSE-2.0).

## Code of Conduct

Everyone interacting in the HotelPrice project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/elsoul/souls/blob/master/CODE_OF_CONDUCT.md).
