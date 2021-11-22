module Souls
  class Delete < Thor
    desc "rspec_manager [CLASS_NAME]", "Delete Rspec Manager Test Template"
    method_option :mutation, aliases: "--mutation", required: true, desc: "Mutation File Name"
    def rspec_manager(class_name)
      singularized_class_name = class_name.underscore.singularize
      file_path = "./spec/mutations/managers/#{singularized_class_name}/#{options[:mutation]}_spec.rb"
      FileUtils.rm_f(file_path)
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
