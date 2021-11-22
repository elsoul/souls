module Souls
  class Delete < Thor
    desc "type_rbs [CLASS_NAME]", "Delete GraphQL Type RBS"
    def type_rbs(class_name)
      singularized_class_name = class_name.underscore.singularize
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/types"
        file_path = "#{file_dir}/#{singularized_class_name}_type.rbs"
        FileUtils.rm_f(file_path)
      end
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
