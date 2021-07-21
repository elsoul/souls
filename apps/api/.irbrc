require "./app"
require "souls"
require "./config/souls"
Dir["./spec/factories/*.rb"].each { |f| require f }
