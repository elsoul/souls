module Mutations
  module Base::Article
    class DeleteArticle < BaseMutation
      field :article, Types::ArticleType, null: false
      argument :id, String, required: true

      def resolve(**args)
        _, data_id = SoulsApiSchema.from_global_id(args[:id])
        article = ::Article.find(data_id)
        article.update(is_deleted: true)
        { article: ::Article.find(data_id) }
      rescue StandardError => e
        GraphQL::ExecutionError.new(e)
      end
    end
  end
end
