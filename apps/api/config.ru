require "./app"
require "rack/cors"
if ENV["RACK_ENV"] == "development"
  require "graphql_playground"

  map "/playground" do
    endpoint = SOULs.configuration.endpoint
    use GraphQLPlayground, endpoint:
  end
end

run SOULsApi

use Rack::Cors do
  allowed_headers = %i[get post put patch delete options head]
  allow do
    origins "*"
    resource "*", headers: :any, methods: allowed_headers
  end
end
