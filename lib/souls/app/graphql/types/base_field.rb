module SOULs
  module Types
    class BaseField < GraphQL::Schema::Field
      argument_class SOULs::Types::BaseArgument
    end
  end
end
