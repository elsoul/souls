module SOULs
  class Delete < Thor
    desc "edge [CLASS_NAME]", "Delete GraphQL Edge"
    def edge(class_name)
      file_dir = "./app/graphql/types/edges/"
      singularized_class_name = class_name.underscore.singularize
      file_path = "#{file_dir}#{singularized_class_name}_edge.rb"
      FileUtils.rm_f(file_path)
      SOULs::Painter.delete_file(file_path.to_s)
      file_path
    end
  end
end
