module Mutations
  module Base::Article
    class CreateArticle < BaseMutation
      field :article_edge, Types::ArticleType.edge_type, null: false
      field :error, String, null: true

      argument :body, String, required: false
      argument :category, String, required: false
      argument :is_deleted, Boolean, required: false
      argument :published, Boolean, required: false
      argument :slug, String, required: false
      argument :tags, [String], required: false
      argument :title, String, required: false
      argument :user_id, String, required: false

      def resolve(args)
        _, user_id = SoulsApiSchema.from_global_id(args[:user_id])
        new_record = { **args, user_id: user_id }
        title_en = translate(text: args[:title], lang: "en")
        body_en = translate(text: args[:body], lang: "en")
        new_record.delete(:body)
        new_record.delete(:title)
        data = ::Article.new(new_record)
        raise(StandardError, data.errors.full_messages) unless data.save

        article_translation = data.article_translations.new(title: title_en, body: body_en)
        article_translation.save

        { article_edge: { node: data } }
      end
    end
  end
end
