module Souls
  class Delete < Thor
    desc "query [CLASS_NAME]", "Delete GraphQL Query"
    def query(class_name)
      singularized_class_name = class_name.singularize
      file_path = "./app/graphql/queries/#{singularized_class_name}*.rb"
      FileUtils.rm_f(file_path)
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
