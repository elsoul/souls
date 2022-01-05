module Mutations
  module Base::Article
    class UpdateArticle < BaseMutation
      field :article_edge, Types::ArticleType.edge_type, null: false
      field :error, String, null: true

      argument :body, String, required: false
      argument :category, String, required: false
      argument :id, String, required: true
      argument :is_deleted, Boolean, required: false
      argument :published, Boolean, required: false
      argument :slug, String, required: false
      argument :tags, [String], required: false
      argument :title, String, required: false

      def resolve(args)
        _, data_id = SOULsApiSchema.from_global_id(args[:id])
        user_id = context[:user][:id]
        new_record = { **args, id: data_id, user_id: user_id }
        data = ::Article.find(data_id)
        data.update(new_record)
        raise(StandardError, data.errors.full_messages) unless data.save

        { article_edge: { node: data } }
      end
    end
  end
end
