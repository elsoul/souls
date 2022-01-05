module Mutations
  module Base::ArticleTranslation
    class CreateArticleTranslation < BaseMutation
      field :article_translation_edge, Types::ArticleTranslationType.edge_type, null: false
      field :error, String, null: true

      argument :article_id, String, required: false
      argument :body, String, required: false
      argument :is_deleted, Boolean, required: false
      argument :title, String, required: false

      def resolve(args)
        _, article_id = SOULsApiSchema.from_global_id(args[:article_id])
        new_record = { **args, article_id: article_id }
        data = ::ArticleTranslation.new(new_record)
        raise(StandardError, data.errors.full_messages) unless data.save

        { article_translation_edge: { node: data } }
      end
    end
  end
end
