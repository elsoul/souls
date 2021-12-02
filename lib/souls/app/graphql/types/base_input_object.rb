module Souls
  module Types
    class BaseInputObject < GraphQL::Schema::InputObject
      argument_class Souls::Types::BaseArgument
    end
  end
end
