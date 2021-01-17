require "grpc"
require "yaml"
require "erb"
require "logger"
require "zeitwerk"
require "dotenv/load"
require "google/cloud/firestore"
require "./app"

ENV["SOULS_ENV"] ||= "development"

# NoSQL Conf
# YAML.safe_load(ERB.new(File.new("./config/mongoid.yml").read).result)

## SQL Conf
# db_conf = YAML.safe_load(ERB.new(File.read("./config/database.yml")).result, [], [], true)
# ActiveRecord::Base.establish_connection(db_conf[ENV["RACK_ENV"]])

loader = Zeitwerk::Loader.new
loader.push_dir("#{Dir.pwd}/app/controllers")
loader.push_dir("#{Dir.pwd}/app/services")
loader.do_not_eager_load("#{Dir.pwd}/app/services")
loader.collapse("#{__dir__}/app/services")
loader.setup

loader.eager_load
