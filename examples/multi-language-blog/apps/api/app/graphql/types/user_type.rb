module Types
  class UserType < SOULs::Types::BaseObject
    implements GraphQL::Types::Relay::Node

    global_id_field :id
    field :created_at, String, null: true
    field :email, String, null: true
    field :is_deleted, Boolean, null: true
    field :lang, String, null: true
    field :uid, String, null: true
    field :updated_at, String, null: true
    field :username, String, null: true
  end
end
