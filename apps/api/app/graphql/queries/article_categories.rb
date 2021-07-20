module Queries
  class ArticleCategories < Queries::BaseQuery
    type [Types::ArticleCategoryType], null: false

    def resolve
      ::ArticleCategory.all
    rescue StandardError => e
      GraphQL::ExecutionError.new(e)
    end
  end
end
