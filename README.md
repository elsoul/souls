[![SOULs](https://firebasestorage.googleapis.com/v0/b/el-quest.appspot.com/o/mediaLibrary%2F1605615287402_souls-ogp.jpg?alt=media&token=1115aa76-6863-469d-acc8-9815ca7fac37)](https://rubygems.org/gems/souls)

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

Welcome to SOULs Framework!

SOULS is a Web Application Framework based on GraphQL Relay ( Ruby )
This is Cloud Based APP Framework. Easy Deployment.
Microservices on Multi Cloud Platform such as Google Cloud Platform, Amazon Web Services, and Alibaba Cloud. Auto deploy with scalable condition. 
You can focus on business logic. No more infra problems.

SOULs creates 5 types of framework.

1. API - GraphQL (Ruby) - Simple API 
2. API - GraphQL to call gRPC (Ruby) - for heavy task processes
3. Service - gRPC Serverless Scalable Service (Ruby)
4. Media Web Client - Media web client with SSG (TypeScript)
5. Admin Web Client - Admin Console and CMS (TypeScript)

## Dependency

- [Google SDK](https://cloud.google.com/sdk/docs)
- [Docker](https://www.docker.com/)
- [Firebase CLI](https://firebase.google.com/docs/cli)

## Cloud Infrastructure

- [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine)
- [Google Traffic Director](https://cloud.google.com/traffic-director)
- [Google Cloud Run](https://cloud.google.com/run)
- [Google Firebase](https://firebase.google.com/)
- [Google Cloud Scheduler](https://cloud.google.com/scheduler)

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

1. API
2. API - gRPC
3. Service
4. Media Web
5. Admin Web

## Usage - 1. GraphQL API

```bash
# Ruby version (using rbenv)
$ ruby -v
ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-darwin20]

# Install xcode
$ xcode-select --install

# Install PostgreSQL (Mac env)
$ brew install postgresql

# Install redis
$ brew install redis

# Version Check
$ souls -v

# Init SOULs App
$ souls new app_name
$ cd app_name
$ bundle

# Run Dev & Test DB
$ souls i run_psql

# Create DB
$ souls db:create

# Migrate DB
$ souls db:migrate

# Create Test DB
$ souls db:seed

# Development (localhost:3000/playground)
$ souls s

# Development with Worker (localhost:3000/playground; localhost:3000/sidekiq)
$ foreman start -f Procfile.dev

# Test
$ bundle exec rspec

# Deploy (Edit: ./cloudbuild.yml)
$ souls deploy

# Run Infra Command
$ souls i `method_name`
```

## SOULs Scaffold
SOULs Scaffold creates CRUD API from `./db/schema.rb`

```bash
# Create migration file
$ souls g migration user

# Edit migration file
# Migrate DB
$ souls db:migrate

# SOULs Scaffold
$ souls g migrate user
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org/gems/souls).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/elsoul/souls. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [Apache-2.0 License](https://www.apache.org/licenses/LICENSE-2.0).

## Code of Conduct

Everyone interacting in the HotelPrice project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/elsoul/souls/blob/master/CODE_OF_CONDUCT.md).
