module Souls
  class Delete < Thor
    desc "policy [CLASS_NAME]", "Delete Policy File Template"
    def policy(class_name)
      dir_name = "./app/policies"
      FileUtils.mkdir_p(dir_name) unless Dir.exist?(dir_name)
      file_path = "#{dir_name}/#{class_name.singularize}_policy.rb"
      FileUtils.rm(file_path)
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
