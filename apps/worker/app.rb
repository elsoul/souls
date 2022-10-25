require "rubygems"
require "bundler/setup"
Bundler.require(:default)
require "sinatra/base"
require "sinatra/json"
require "json"
require "logger"
require "erb"
require "./config/souls"
require "./config/souls_logger"

ENV["RACK_ENV"] ||= "development"
@app_name = SOULs.configuration.app

loader = Zeitwerk::Loader.new

loader.push_dir("#{Dir.pwd}/lib")
loader.setup

class SOULsApi < Sinatra::Base
  ::Logger.class_eval { alias_method :write, :<< }
  access_log = ::File.join(::File.dirname(::File.expand_path(__FILE__)), "log", "access.log")
  access_logger = ::Logger.new(access_log)
  error_logger = ::File.new(::File.join(::File.dirname(::File.expand_path(__FILE__)), "log", "error.log"), "a+")
  error_logger.sync = true

  use Rack::JSONBodyParser

  configure :production, :development do
    set :logger, Logger.new($stdout)
    enable :logging
    use ::Rack::CommonLogger, access_logger
  end

  before { env["rack.errors"] = error_logger }

  error StandardError do
    StandardError.to_json
  end

  post "/run" do
    message = { define: "method here" }
    json message
  end

  get "/" do
    message = { success: true, message: "SOULs Worker is Running!", env: ENV.fetch("RACK_ENV", nil) }
    json message
  end
end
