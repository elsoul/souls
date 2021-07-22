module Mutations
  module Base::Article
    class DestroyDeleteArticle < BaseMutation
      field :article, Types::ArticleType, null: false
      argument :id, String, required: true

      def resolve(**args)
        _, data_id = SoulsApiSchema.from_global_id(args[:id])
        article = ::Article.find(data_id)
        article.destroy
        { article: article }
      rescue StandardError => e
        GraphQL::ExecutionError.new(e)
      end
    end
  end
end
