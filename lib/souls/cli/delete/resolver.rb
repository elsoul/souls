module Souls
  class Delete < Thor
    desc "resolver [CLASS_NAME]", "Delete GraphQL Resolver"
    def resolver(class_name)
      singularized_class_name = class_name.singularize.underscore
      file_path = "./app/graphql/resolvers/#{singularized_class_name}_search.rb"
      FileUtils.rm(file_path)
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
