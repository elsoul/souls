module Souls
  class Delete < Thor
    desc "mutation_rbs [CLASS_NAME]", "Delete GraphQL Mutation RBS"
    def mutation_rbs(class_name)
      singularized_class_name = class_name.underscore.singularize
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/mutations/base/#{singularized_class_name}"
        FileUtils.rm_rf(file_dir)
      end
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
