module Mutations
  module Base::ArticleCategory
    class CreateArticleCategory < BaseMutation
      field :article_category_edge, Types::ArticleCategoryType.edge_type, null: false
      field :error, String, null: true

      argument :is_deleted, Boolean, required: false
      argument :name, String, required: false
      argument :tags, [String], required: false

      def resolve(**args)
        data = ::ArticleCategory.new(args)
        raise(StandardError, data.errors.full_messages) unless data.save

        { article_category_edge: { node: data } }
      rescue StandardError => e
        GraphQL::ExecutionError.new(e)
      end
    end
  end
end
