module Mutations
  module Base::Article
    class UpdateArticle < BaseMutation
      field :article_edge, Types::ArticleType.edge_type, null: false

      argument :article_category_id, String, required: false
      argument :body, String, required: false
      argument :id, String, required: true
      argument :is_deleted, Boolean, required: false
      argument :is_public, Boolean, required: false
      argument :just_created, Boolean, required: false
      argument :public_date, GraphQL::Types::ISO8601DateTime, required: false
      argument :slag, String, required: false
      argument :tags, [String], required: false
      argument :thumnail_url, String, required: false
      argument :title, String, required: false

      def resolve(**args)
        args[:user_id] = context[:user].id
        _, args[:id] = SoulsApiSchema.from_global_id(args[:id])
        _, args[:article_category_id] = SoulsApiSchema.from_global_id(args[:article_category_id])
        article = ::Article.find(args[:id])
        article.update(args)
        { article_edge: { node: ::Article.find(args[:id]) } }
      rescue StandardError => e
        GraphQL::ExecutionError.new(e)
      end
    end
  end
end
