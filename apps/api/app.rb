require "erb"
require "jwt"
require "json"
require "sinatra"
require "rubygems"
require "bundler/setup"
Bundler.require(:default)
require "dotenv/load"
require "sinatra/base"
require "sinatra/json"
require "sinatra/activerecord"
require "rack/contrib"
require "active_support"
require "active_support/core_ext"
require "logger"
require "base64"
require "search_object"
require "search_object/plugin/graphql"
require "./config/souls"
require "./config/souls_logger"

ENV["RACK_ENV"] ||= "development"
Dir["./constants/*.rb"].each { |f| require f }
@app_name = SOULs.configuration.app
db_conf = YAML.safe_load(ERB.new(File.read("./config/database.yml")).result, permitted_classes: [Date], aliases: true)
ActiveRecord::Base.establish_connection(db_conf[ENV.fetch("RACK_ENV", nil)])
ActiveRecord.default_timezone = :local

loader = Zeitwerk::Loader.new
loader.push_dir("#{Dir.pwd}/app/models")
loader.push_dir("#{Dir.pwd}/app/utils")

loader.collapse("#{__dir__}/app/types")
loader.collapse("#{__dir__}/app/mutations")
loader.collapse("#{__dir__}/app/queries")
loader.collapse("#{__dir__}/app/resolvers")
loader.collapse("#{__dir__}/app/graphql/types/connections")
loader.collapse("#{__dir__}/app/graphql/types/edges")
loader.collapse("#{__dir__}/app/graphql/types/base")
loader.push_dir("#{Dir.pwd}/app/graphql")
loader.setup

class SOULsApi < Sinatra::Base
  ::Logger.class_eval { alias_method :write, :<< }
  access_log = ::File.join(::File.dirname(::File.expand_path(__FILE__)), "log", "access.log")
  access_logger = ::Logger.new(access_log)
  error_logger = ::File.new(::File.join(::File.dirname(::File.expand_path(__FILE__)), "log", "error.log"), "a+")
  error_logger.sync = true

  use Rack::JSONBodyParser
  register Sinatra::ActiveRecordExtension
  endpoint = SOULs.configuration.endpoint

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
    message = { success: true, message: "SOULs API is Running!", env: ENV.fetch("RACK_ENV", nil) }
    json message
  end

  get "/db" do
    message = {
      success: true,
      message: "SOULs API is Running!",
      env: ENV.fetch("RACK_ENV", nil),
      db: User.first.username
    }
    json(message)
  rescue StandardError => e
    message = { error: e }
    json(message)
  end

  post endpoint do
    token = request.env["HTTP_AUTHORIZATION"].split("Bearer ")[1] if request.env["HTTP_AUTHORIZATION"]

    user = token ? login_auth(token:) : nil
    context = { user: }
    result = SOULsApiSchema.execute(params[:query], variables: params[:variables], context:)
    json(result)
  rescue StandardError => e
    message = { error: e }
    json(message)
  end

  def login_auth(token:)
    decoded_token = JsonWebToken.decode(token)
    user_id = decoded_token[:user_id]
    user = User.find(user_id)
    raise(StandardError, "Invalid or Missing Token") if user.blank?

    user
  rescue StandardError => e
    message = { error: e }
    json(message)
  end
end
