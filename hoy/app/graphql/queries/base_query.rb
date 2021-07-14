module Queries
  class BaseQuery < GraphQL::Schema::Resolver
    def blog_host
      return "localhost:50051" if Sinatra.env.development? || Sinatra.env.test?

      ENV["GRPC_SERVER_URL1"]
    end
  end
end
