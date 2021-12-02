module Souls
  module Types
    class BaseField < GraphQL::Schema::Field
      argument_class Souls::Types::BaseArgument
    end
  end
end
