module SOULs
  class Delete < Thor
    desc "type_rbs [CLASS_NAME]", "Delete GraphQL Type RBS"
    def type_rbs(class_name)
      singularized_class_name = class_name.underscore.singularize
      file_path = ""
      Dir.chdir(SOULs.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/types"
        file_path = "#{file_dir}/#{singularized_class_name}_type.rbs"
        FileUtils.rm_f(file_path)
      end
      SOULs::Painter.delete_file(file_path.to_s)
      file_path
    end
  end
end
