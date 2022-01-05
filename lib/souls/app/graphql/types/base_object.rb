module SOULs
  module Types
    class BaseObject < GraphQL::Schema::Object
      field_class SOULs::Types::BaseField
      connection_type_class SOULs::SOULsConnection
    end
  end
end
