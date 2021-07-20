require "./app"
require "rack/cors"
require "graphql_playground"

map "/playground" do
  use GraphQLPlayground, endpoint: "/endpoint"
end

run SoulsApi

use Rack::Cors do
  allowed_headers = %i[get post put patch delete options head]
  allow do
    origins "*"
    resource "*", headers: :any, methods: allowed_headers
  end
end
