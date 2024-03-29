module SOULs
  class Delete < Thor
    desc "rspec_mutation [CLASS_NAME]", "Delete Rspec Mutation Test from schema.rb"
    def rspec_mutation(class_name)
      singularized_class_name = class_name.singularize
      file_path = "./spec/mutations/base/#{singularized_class_name}_spec.rb"
      FileUtils.rm_f(file_path)
      SOULs::Painter.delete_file(file_path.to_s)
      file_path
    end
  end
end
