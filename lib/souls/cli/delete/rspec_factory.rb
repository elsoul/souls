module Souls
  class Delete < Thor
    desc "rspec_factory [CLASS_NAME]", "Delete Rspec Factory Test from schema.rb"
    def rspec_factory(class_name)
      file_path = "./spec/factories/#{class_name.pluralize}.rb"
      FileUtils.rm(file_path)
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
