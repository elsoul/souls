require "active_support"
require "active_support/core_ext"
require "erb"
require "csv"
require "jwt"
require "json"
require "sinatra"
require "sinatra/base"
require "sinatra/json"
require "sinatra/activerecord"
require "rack/contrib"
require "zeitwerk"
require "factory_bot"
require "faker"
require "dotenv/load"
require "graphql"
require "google/cloud/firestore"
require "google/cloud/storage"
require "google/cloud/pubsub"
require "logger"
require "base64"
require "slack/ruby3"
require "role_model"
require "pundit"
require "sendgrid-ruby"
require "search_object"
require "search_object/plugin/graphql"
require "graphql/batch"

ENV["RACK_ENV"] ||= "development"
Dir["./config/*.rb"].each { |f| require f unless f.include?("souls.rb") }
Dir["./constants/*.rb"].each { |f| require f }

db_conf = YAML.safe_load(ERB.new(File.read("./config/database.yml")).result, permitted_classes: [Date], aliases: true)
ActiveRecord::Base.establish_connection(db_conf[ENV["RACK_ENV"]])
ActiveRecord::Base.default_timezone = :local

loader = Zeitwerk::Loader.new
loader.push_dir("#{Dir.pwd}/app/models")
loader.push_dir("#{Dir.pwd}/app/utils")
loader.push_dir("#{Dir.pwd}/app/engines")

loader.collapse("#{__dir__}/app/types")
loader.collapse("#{__dir__}/app/mutations")
loader.collapse("#{__dir__}/app/graphql/types/base")
loader.push_dir("#{Dir.pwd}/app/graphql")
loader.setup

class SoulsApi < Sinatra::Base
  include Pundit
  include SoulsHelper
  ::Logger.class_eval { alias_method :write, :<< }
  access_log = ::File.join(::File.dirname(::File.expand_path(__FILE__)), "log", "access.log")
  access_logger = ::Logger.new(access_log)
  error_logger = ::File.new(::File.join(::File.dirname(::File.expand_path(__FILE__)), "log", "error.log"), "a+")
  error_logger.sync = true

  use Rack::JSONBodyParser
  register Sinatra::ActiveRecordExtension

  configure :production, :development do
    set :logger, Logger.new($stdout)
    enable :logging
    use ::Rack::CommonLogger, access_logger
  end

  before { env["rack.errors"] = error_logger }

  error StandardError do
    StandardError.to_json
  end

  get "/" do
    message = { success: true, message: "SOULs Running!", env: ENV["RACK_ENV"] }
    json message
  end

  get "/db" do
    message = { success: true, message: "SOULs Running!", env: ENV["RACK_ENV"], db: User.first.username }
    json(message)
  rescue StandardError => e
    message = { error: e }
    json(message)
  end

  post "/endpoint" do
    query =
      if ENV["RACK_ENV"] == "production"
        Base64.decode64(params["message"]["data"]).force_encoding("UTF-8")
      else
        params[:query]
      end

    result = SoulsApiSchema.execute(query.to_s)
    json(result)
  rescue StandardError => e
    NotificationEngine.send_slack_error(e.backtrace)
    message = { error: e.backtrace }
    json(message)
  end
end
