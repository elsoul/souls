module Souls
  class Delete < Thor
    desc "rspec_resolver [CLASS_NAME]", "Delete Rspec Resolver Test"
    def rspec_resolver(class_name)
      singularized_class_name = class_name.singularize
      file_path = "./spec/resolvers/#{singularized_class_name}_search_spec.rb"
      FileUtils.rm(file_path)
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
