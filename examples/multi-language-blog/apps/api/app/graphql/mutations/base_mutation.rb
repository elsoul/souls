module Mutations
  class BaseMutation < Souls::SoulsMutation
    argument_class Souls::Types::BaseArgument
    field_class Souls::Types::BaseField
    input_object_class Souls::Types::BaseInputObject
    object_class Souls::Types::BaseObject

    def translate(text:, lang: "ja")
      translate = Google::Cloud::Translate::V2.new(project_id: "el-quest")
      translation = translate.translate(text, to: lang)
      translation.text
    end
  end
end
