require "./app"
require "souls"
require "./config/souls"
require "faker"
require "factory_bot"
Dir["./spec/factories/*.rb"].each { |f| require f }
