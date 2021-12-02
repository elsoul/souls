module Souls
  module Types
    class BaseObject < GraphQL::Schema::Object
      field_class Souls::Types::BaseField
      connection_type_class Souls::SoulsConnection
    end
  end
end
