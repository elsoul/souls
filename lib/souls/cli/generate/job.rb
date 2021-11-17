module Souls
  class Generate < Thor
    desc "job [CLASS_NAME]", "Generate Job File in Worker"
    method_option :mailer, type: :boolean, aliases: "--mailer", default: false, desc: "Mailer Option"
    def job(class_name)
      if options[:mailer]
        create_job_mailer_type(class_name)
        mailgun_mailer(class_name)
      else
        create_job_type(class_name)
        create_job(class_name)
      end
      Souls::Generate.new.invoke(:job_rbs, [class_name], {})
      Souls::Generate.new.invoke(:rspec_job, [class_name], { mailer: options[:mailer] })
    end

    private

    def create_job(class_name)
      file_dir = "./app/graphql/queries/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{class_name.singularize}.rb"
      raise(StandardError, "Query already exist! #{file_path}") if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Queries
            class #{class_name.camelize} < BaseQuery
              description ""
              type Types::#{class_name.camelize}Type, null: false

              def resolve
                # Difine method here
                { response: "Job done!" }
              end
            end
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    end

    def create_job_type(class_name)
      file_dir = "./app/graphql/types/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{class_name.singularize}_type.rb"
      raise(StandardError, "Type already exists! #{file_path}") if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Types
            class #{class_name.camelize}Type < BaseObject
              field :response, String, null: true
            end
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    end

    def mailgun_mailer(class_name)
      file_dir = "./app/graphql/queries/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{class_name.singularize}.rb"
      raise(StandardError, "Mailer already exists! #{file_path}") if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Queries
            class #{class_name.camelize} < BaseQuery
              description ""
              type Types::#{class_name.camelize}Type, null: false

              def resolve
                # First, instantiate the Mailgun Client with your API key
                mg_client = ::Mailgun::Client.new(ENV['MAILGUN_KEY'])

                # Define your message parameters
                message_params = {
                  from: "postmaster@from.mail.com",
                  to: "sending@to.mail.com",
                  subject: "SOULs Mailer test!",
                  text: "It is really easy to send a message!"
                }

                # Send your message through the client
                mg_client.send_message(ENV['MAILGUN_DOMAIN'], message_params)
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

    def create_job_mailer_type(class_name)
      file_dir = "./app/graphql/types/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}#{class_name.singularize}_type.rb"
      raise(StandardError, "Type already exists! #{file_path}") if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Types
            class #{class_name.camelize}Type < BaseObject
              field :response, String, null: true
            end
          end
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
