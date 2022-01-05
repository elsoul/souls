module Mutations
  module Base::ArticleTranslation
    class UpdateArticleTranslation < BaseMutation
      field :article_translation_edge, Types::ArticleTranslationType.edge_type, null: false
      field :error, String, null: true

      argument :article_id, String, required: false
      argument :body, String, required: false
      argument :id, String, required: true
      argument :is_deleted, Boolean, required: false
      argument :title, String, required: false

      def resolve(args)
        _, data_id = SOULsApiSchema.from_global_id(args[:id])
        _, article_id = SOULsApiSchema.from_global_id(args[:article_id])
        new_record = { **args, id: data_id, article_id: article_id }
        data = ::ArticleTranslation.find(data_id)
        data.update(new_record)
        raise(StandardError, data.errors.full_messages) unless data.save

        { article_translation_edge: { node: data } }
      end
    end
  end
end
