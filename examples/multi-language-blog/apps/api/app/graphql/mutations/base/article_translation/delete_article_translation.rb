module Mutations
  module Base::ArticleTranslation
    class DeleteArticleTranslation < BaseMutation
      field :article_translation, Types::ArticleTranslationType, null: false
      argument :id, String, required: true

      def resolve(args)
        _, data_id = SoulsApiSchema.from_global_id(args[:id])
        article_translation = ::ArticleTranslation.find(data_id)
        article_translation.update(is_deleted: true)
        { article_translation: ::ArticleTranslation.find(data_id) }
      end
    end
  end
end
