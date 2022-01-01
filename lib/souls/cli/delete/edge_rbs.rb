module Souls
  class Delete < Thor
    desc "edge_rbs [CLASS_NAME]", "Delete GraphQL Edge RBS"
    def edge_rbs(class_name)
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/types/edges/"
        singularized_class_name = class_name.underscore.singularize
        file_path = "#{file_dir}#{singularized_class_name}_edge.rbs"
        FileUtils.rm_f(file_path)
        Souls::Painter.delete_file(file_path)
        file_path
      end
    end
  end
end
