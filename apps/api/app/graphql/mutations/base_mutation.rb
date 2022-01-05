module Mutations
  class BaseMutation < SOULs::SOULsMutation
    argument_class SOULs::Types::BaseArgument
    field_class SOULs::Types::BaseField
    input_object_class SOULs::Types::BaseInputObject
    object_class SOULs::Types::BaseObject
  end
end
