module Queries
  class ArticleTranslation < Queries::BaseQuery
    type Types::ArticleTranslationType, null: false
    argument :id, String, required: true

    def resolve(args)
      _, data_id = SoulsApiSchema.from_global_id(args[:id])
      ::ArticleTranslation.find(data_id)
    end
  end
end
