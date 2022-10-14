require "./app"
require "faker"
require "factory_bot"

Dir[File.expand_path("#{Rack::Directory.new('').root}/spec/factories/*.rb")]
  .each { |file| require file }
Faker::Config.locale = "ja"
