module Souls
  class Generate < Thor
    desc "job [CLASS_NAME]", "Generate Job File in Worker"
    method_option :mutation, type: :boolean, aliases: "--mailer", default: false, desc: "Mailer Option"
    def job(class_name)
      if options[:mailer]
        mailgun_mailer(class_name: class_name)
      else
        create_job_mutation(class_name: class_name)
      end
      Souls::Generate.new.invoke(:job_rbs, [class_name], {})
      Souls::Generate.new.invoke(:rspec_job, [class_name], {})
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    private

    def create_job_mutation(class_name: "send-mailer")
      file_dir = "./app/graphql/mutations/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{class_name.singularize}.rb"
      raise(StandardError, "Mutation already exist! #{file_path}") if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Mutations
            class #{class_name.camelize} < BaseMutation
              description "Job Description"
              field :response, String, null: false

              def resolve
                # Define Job Here

                { response: "Job done!" }
              rescue StandardError => e
                GraphQL::ExecutionError.new(e.to_s)
              end
            end
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    end

    def mailgun_mailer(class_name: "mailer")
      file_dir = "./app/graphql/mutations/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{class_name.singularize}.rb"
      raise(StandardError, "Mailer already exist! #{file_path}") if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Mutations
            class #{class_name.camelize} < BaseMutation
              description "Mail を送信します。"
              field :response, String, null: false

              def resolve
                # First, instantiate the Mailgun Client with your API key
                mg_client = ::Mailgun::Client.new("YOUR-API-KEY")

                # Define your message parameters
                message_params = {
                  from: "postmaster@YOUR-DOMAIN",
                  to: "sending@to.mail.com",
                  subject: "SOULs Mailer test!",
                  text: "It is really easy to send a message!"
                }

                # Send your message through the client
                mg_client.send_message("YOUR-MAILGUN-DOMAIN", message_params)
                { response: "Job done!" }
              rescue StandardError => e
                GraphQL::ExecutionError.new(e.to_s)
              end
            end
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
