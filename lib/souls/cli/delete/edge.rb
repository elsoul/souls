module Souls
  class Delete < Thor
    desc "edge [CLASS_NAME]", "Delete GraphQL Edge"
    def edge(class_name)
      file_dir = "./app/graphql/types/edges"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      singularized_class_name = class_name.underscore.singularize
      file_path = "./app/graphql/types/edges/#{singularized_class_name}_edge.rb"
      FileUtils.rm(file_path)
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
