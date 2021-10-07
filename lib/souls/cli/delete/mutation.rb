module Souls
  class Delete < Thor
    desc "mutation [CLASS_NAME]", "Delete GraphQL Mutation"
    def mutation(class_name)
      singularized_class_name = class_name.singularize
      file_path = ""
      Dir.chdir(Souls.get_api_path.to_s) do
        file_path = "./app/graphql/mutations/base/#{singularized_class_name}/"
        FileUtils.rm_rf(file_path)
      end
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
