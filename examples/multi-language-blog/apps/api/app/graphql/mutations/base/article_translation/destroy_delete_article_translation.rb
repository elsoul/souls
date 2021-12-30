module Mutations
  module Base::ArticleTranslation
    class DestroyDeleteArticleTranslation < BaseMutation
      field :article_translation, Types::ArticleTranslationType, null: false
      argument :id, String, required: true

      def resolve(args)
        _, data_id = SoulsApiSchema.from_global_id(args[:id])
        article_translation = ::ArticleTranslation.find(data_id)
        article_translation.destroy
        { article_translation: article_translation }
      end
    end
  end
end
