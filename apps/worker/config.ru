require "./app"
require "rack/cors"

run SOULsApi

use Rack::Cors do
  allowed_headers = %i[get post put patch delete options head]
  allow do
    origins "*"
    resource "*", headers: :any, methods: allowed_headers
  end
end
