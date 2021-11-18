module Souls
  class Delete < Thor
    desc "job [CLASS_NAME]", "Delete Job File in Worker"
    method_option :mailer, type: :boolean, aliases: "--mailer", default: false, desc: "Mailer Option"
    def job(class_name)
      if options[:mailer]
        mailgun_mailer(class_name: class_name)
      else
        delete_job_mutation(class_name: class_name)
      end
      Souls::Delete.new.invoke(:job_rbs, [class_name], {})
      Souls::Delete.new.invoke(:rspec_job, [class_name], {})
    end

    private

    def delete_job_mutation(class_name: "send-mailer")
      file_dir = "./app/graphql/mutations/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{class_name.singularize}.rb"

      FileUtils.rm(file_path)
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    end

    def mailgun_mailer(class_name: "mailer")
      file_dir = "./app/graphql/mutations/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{class_name.singularize}.rb"

      FileUtils.rm(file_path)
      puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
