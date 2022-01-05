module SOULs
  class Delete < Thor
    desc "resolver [CLASS_NAME]", "Delete GraphQL Resolver"
    def resolver(class_name)
      singularized_class_name = class_name.singularize.underscore
      file_path = "./app/graphql/resolvers/#{singularized_class_name}_search.rb"
      FileUtils.rm_f(file_path)
      SOULs::Painter.delete_file(file_path.to_s)
      file_path
    end
  end
end
