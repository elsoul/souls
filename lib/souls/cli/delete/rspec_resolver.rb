module SOULs
  class Delete < Thor
    desc "rspec_resolver [CLASS_NAME]", "Delete Rspec Resolver Test"
    def rspec_resolver(class_name)
      singularized_class_name = class_name.singularize
      file_path = "./spec/resolvers/#{singularized_class_name}_search_spec.rb"
      FileUtils.rm_f(file_path)
      SOULs::Painter.delete_file(file_path.to_s)
      file_path
    end
  end
end
