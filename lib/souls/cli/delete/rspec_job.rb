module Souls
  class Delete < Thor
    desc "rspec_job [CLASS_NAME]", "Delete Rspec Job Test Template"
    def rspec_job(class_name)
      singularized_class_name = class_name.underscore.singularize
      file_path = "#{file_dir}/#{singularized_class_name}_spec.rb"
      FileUtils.rm(file_path)
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
