module SOULs
  class Delete < Thor
    desc "job_rbs [CLASS_NAME]", "Delete SOULs Job Mutation RBS Template"
    def job_rbs(class_name)
      file_path = ""
      worker_name = FileUtils.pwd.split("/").last
      if worker_name == "api" || FileUtils.pwd.split("/")[-2] != "apps"
        raise(SOULs::CLIException, "This task must be run from within a worker directory")
      end

      Dir.chdir(SOULs.get_mother_path.to_s) do
        singularized_class_name = class_name.underscore.singularize
        file_dir = "./sig/#{worker_name}/app/graphql/queries/"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        file_path = "#{file_dir}#{singularized_class_name}.rbs"
        FileUtils.rm_f(file_path)
        SOULs::Painter.delete_file(file_path.to_s)
      end
      file_path
    end
  end
end
