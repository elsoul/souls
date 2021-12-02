module Mutations
  class BaseMutation < Souls::SoulsMutation
    argument_class Souls::Types::BaseArgument
    field_class Souls::Types::BaseField
    input_object_class Souls::Types::BaseInputObject
    object_class Souls::Types::BaseObject
  end
end
