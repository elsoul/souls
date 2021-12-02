module Souls
  module Types
    module BaseInterface
      include GraphQL::Schema::Interface

      field_class Souls::Types::BaseField
    end
  end
end
