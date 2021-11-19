module Souls
  class Delete < Thor
    desc "job [CLASS_NAME]", "Delete Job File in Worker"
    method_option :mailer, type: :boolean, aliases: "--mailer", default: false, desc: "Mailer Option"
    def job(class_name)
      file_dir = "./app/graphql/queries/"
      file_path = "#{file_dir}#{class_name.singularize}.rb"

      FileUtils.rm_f(file_path)
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      Souls::Delete.new.invoke(:job_rbs, [class_name], {})
      Souls::Delete.new.invoke(:rspec_job, [class_name], {})
    end
  end
end
