module Mutations
  module Base::ArticleCategory
    class UpdateArticleCategory < BaseMutation
      field :article_category_edge, Types::ArticleCategoryType.edge_type, null: false

      argument :id, String, required: true
      argument :is_deleted, Boolean, required: false
      argument :name, String, required: false
      argument :tags, [String], required: false

      def resolve(**args)
        _, args[:id] = SoulsApiSchema.from_global_id(args[:id])
        article_category = ::ArticleCategory.find(args[:id])
        article_category.update(args)
        { article_category_edge: { node: ::ArticleCategory.find(args[:id]) } }
      rescue StandardError => e
        GraphQL::ExecutionError.new(e)
      end
    end
  end
end
