module SOULs
  class Delete < Thor
    desc "query_rbs [CLASS_NAME]", "Delete GraphQL Query RBS"
    def query_rbs(class_name)
      file_path = ""
      Dir.chdir(SOULs.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/queries/"
        singularized_class_name = class_name.underscore.singularize
        file_path = "#{file_dir}#{singularized_class_name}*.rbs"
        FileUtils.rm_f(file_path)
        SOULs::Painter.delete_file(file_path.to_s)
        file_path
      end
    end
  end
end
