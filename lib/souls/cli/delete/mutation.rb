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
      Souls::Painter.delete_file(file_path.to_s)
      file_path
    end
  end
end
