module Souls
  class Delete < Thor
    desc "connection [CLASS_NAME]", "Delete GraphQL Connection"
    def connection(class_name)
      file_dir = "./app/graphql/types/connections/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      singularized_class_name = class_name.underscore.singularize
      file_path = "./app/graphql/types/connections/#{singularized_class_name}_connection.rb"
      FileUtils.rm(file_path)
      puts(Paint % ["Delete file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
