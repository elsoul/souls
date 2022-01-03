require "functions_framework"
require "sinatra/base"
require "dotenv/load"

class App < Sinatra::Base
  get "/souls-functions-get/:name" do
    "SOULs Functions Job Done! - #{params['name']}"
  end

  post "/souls-functions-post" do
    params = JSON.parse(request.body.read)
    "SOULs Functions Job Done! - #{params['name']}"
  end
end

FunctionsFramework.http("cf_ruby27_discord") do |request|
  App.call(request.env)
end
