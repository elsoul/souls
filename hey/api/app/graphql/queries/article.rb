module Queries
  class Article < Queries::BaseQuery
    type Types::ArticleType, null: false
    argument :id, String, required: true

    def resolve(**args)
      _, data_id = SoulsApiSchema.from_global_id(args[:id])
      ::Article.find(data_id)
    rescue StandardError => e
      GraphQL::ExecutionError.new(e)
    end
  end
end
