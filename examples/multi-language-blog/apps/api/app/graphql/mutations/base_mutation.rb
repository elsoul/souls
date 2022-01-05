module Mutations
  class BaseMutation < SOULs::SOULsMutation
    argument_class SOULs::Types::BaseArgument
    field_class SOULs::Types::BaseField
    input_object_class SOULs::Types::BaseInputObject
    object_class SOULs::Types::BaseObject

    def translate(text:, lang: "ja")
      translate = Google::Cloud::Translate::V2.new(project_id: "el-quest")
      translation = translate.translate(text, to: lang)
      translation.text
    end
  end
end
