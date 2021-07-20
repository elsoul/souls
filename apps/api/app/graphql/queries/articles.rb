module Queries
  class Articles < Queries::BaseQuery
    type [Types::ArticleType], null: false

    def resolve
      ::Article.all
    rescue StandardError => e
      GraphQL::ExecutionError.new(e)
    end
  end
end
