module SOULs
  class Delete < Thor
    desc "rspec_manager [CLASS_NAME]", "Delete Rspec Manager Test Template"
    method_option :mutation, aliases: "--mutation", required: true, desc: "Mutation File Name"
    def rspec_manager(class_name)
      singularized_class_name = class_name.underscore.singularize
      file_path = "./spec/mutations/managers/#{singularized_class_name}/#{options[:mutation]}_spec.rb"
      FileUtils.rm_f(file_path)
      SOULs::Painter.delete_file(file_path.to_s)
      file_path
    end
  end
end
