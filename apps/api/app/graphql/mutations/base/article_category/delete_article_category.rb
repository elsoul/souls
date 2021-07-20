module Mutations
  module Base::ArticleCategory
    class DeleteArticleCategory < BaseMutation
      field :article_category, Types::ArticleCategoryType, null: false
      argument :id, String, required: true

      def resolve(**args)
        _, data_id = SoulsApiSchema.from_global_id(args[:id])
        article_category = ::ArticleCategory.find(data_id)
        article_category.update(is_deleted: true)
        { article_category: ::ArticleCategory.find(data_id) }
      rescue StandardError => e
        GraphQL::ExecutionError.new(e)
      end
    end
  end
end
