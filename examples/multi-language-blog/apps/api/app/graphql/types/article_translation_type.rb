module Types
  class ArticleTranslationType < Souls::Types::BaseObject
    implements GraphQL::Types::Relay::Node

    global_id_field :id
    field :article, Types::ArticleType, null: false
    field :body, String, null: true
    field :created_at, String, null: true
    field :is_deleted, Boolean, null: true
    field :title, String, null: true
    field :updated_at, String, null: true
  end
end
