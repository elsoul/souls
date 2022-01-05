module SOULs
  module Types
    class BaseInputObject < GraphQL::Schema::InputObject
      argument_class SOULs::Types::BaseArgument
    end
  end
end
