source "https://rubygems.org"

gem "activerecord", require: "active_record"
gem "dotenv", "2.7.6"
gem "grpc", "1.34.0"
gem "grpc-tools", "1.34.0"
gem "jwt", "2.2.2"
gem "rake", "13.0.3"
gem "zeitwerk", "2.4.2"

## Select DB gem.
# Firestore
gem "google-cloud-firestore"

# NoSQL
# gem "mongoid", "7.2"

# PostgreSQL
# gem "pg", ">= 0.18", "< 2.0"

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "capybara", "2.18.0"
  gem "capybara-user_agent", "0.0.3"
  gem "database_cleaner", "1.8.5"
  gem "factory_bot", "6.1.0"
  gem "faker", "2.15.1"
  gem "rack-test", "1.1.0"
  gem "rspec", "3.10.0"
  gem "rubocop", "1.7.0"
  gem "souls", "0.8.0"
  gem "webmock", "3.11.0"
end

group :development do
  gem "listen", "~> 3.2"
  gem "spring", "2.1.0"
  gem "spring-watcher-listen", "~> 2.0.0"
end

gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
