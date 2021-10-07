module Souls
  class Delete < Thor
    desc "job_rbs [CLASS_NAME]", "Delete SOULs Job Mutation RBS Template"
    def job_rbs(class_name)
      file_path = ""
      worker_name = FileUtils.pwd.split("/").last
      Dir.chdir(Souls.get_mother_path.to_s) do
        singularized_class_name = class_name.underscore.singularize
        file_dir = "./sig/#{worker_name}/app/graphql/mutations/"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        file_path = "#{file_dir}#{singularized_class_name}.rbs"
        FileUtils.rm(file_path)
        puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      end
      file_path
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
