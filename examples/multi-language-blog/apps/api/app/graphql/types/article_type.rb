module Types
  class ArticleType < Souls::Types::BaseObject
    implements GraphQL::Types::Relay::Node

    global_id_field :id
    field :category, String, null: true
    field :created_at, String, null: true
    field :is_deleted, Boolean, null: true
    field :published, Boolean, null: true
    field :slug, String, null: true
    field :tags, [String], null: true
    field :updated_at, String, null: true
    field :user, Types::UserType, null: false
  end
end
