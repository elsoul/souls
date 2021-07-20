module Queries
  class ArticleCategory < Queries::BaseQuery
    type Types::ArticleCategoryType, null: false
    argument :id, String, required: true

    def resolve(**args)
      _, data_id = SoulsApiSchema.from_global_id(args[:id])
      ::ArticleCategory.find(data_id)
    rescue StandardError => e
      GraphQL::ExecutionError.new(e)
    end
  end
end
