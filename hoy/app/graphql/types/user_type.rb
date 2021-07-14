module Types
  class UserType < BaseObject
    implements GraphQL::Types::Relay::Node

    global_id_field :id
    field :birthday, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :email, String, null: true
    field :first_name, String, null: true
    field :first_name_kana, String, null: true
    field :first_name_kanji, String, null: true
    field :icon_url, String, null: true
    field :last_name, String, null: true
    field :last_name_kana, String, null: true
    field :last_name_kanji, String, null: true
    field :screen_name, String, null: true
    field :tel, String, null: true
    field :uid, String, null: true
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :username, String, null: true
  end
end
