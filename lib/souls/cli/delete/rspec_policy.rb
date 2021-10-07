module Souls
  class Delete < Thor
    desc "rspec_policy [CLASS_NAME]", "Delete Rspec Policy Test"
    def rspec_policy(class_name)
      singularized_class_name = class_name.singularize
      file_path = "./spec/policies/#{singularized_class_name}_policy_spec.rb"
      FileUtils.rm(file_path)
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
