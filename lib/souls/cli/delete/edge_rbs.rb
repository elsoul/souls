module Souls
  class Delete < Thor
    desc "edge_rbs [CLASS_NAME]", "Delete GraphQL Edge RBS"
    def edge_rbs(class_name)
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/types/edges/"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        singularized_class_name = class_name.underscore.singularize
        file_path = "#{file_dir}#{singularized_class_name}_edge.rbs"
        FileUtils.rm(file_path)
        puts(Paint % ["Delete file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      end
      file_path
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
