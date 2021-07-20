module Mutations
  module Base::ArticleCategory
    class DestroyDeleteArticleCategory < BaseMutation
      field :article_category, Types::ArticleCategoryType, null: false
      argument :id, String, required: true

      def resolve(**args)
        _, data_id = SoulsApiSchema.from_global_id(args[:id])
        article_category = ::ArticleCategory.find(data_id)
        article_category.destroy
        { article_category: article_category }
      rescue StandardError => e
        GraphQL::ExecutionError.new(e)
      end
    end
  end
end
