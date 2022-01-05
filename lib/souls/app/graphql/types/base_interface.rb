module SOULs
  module Types
    module BaseInterface
      include GraphQL::Schema::Interface

      field_class SOULs::Types::BaseField
    end
  end
end
