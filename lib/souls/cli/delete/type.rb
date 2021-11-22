module Souls
  class Delete < Thor
    desc "type [CLASS_NAME]", "Delete GraphQL Type"
    def type(class_name)
      singularized_class_name = class_name.singularize
      file_path = "./app/graphql/types/#{singularized_class_name}_type.rb"
      FileUtils.rm_f(file_path)
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
