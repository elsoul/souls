module Souls
  module Worker
    module Generate
      class << self
        def mailgun_mailer(class_name: "mailer")
          file_dir = "./app/graphql/mutations/mailers/"
          FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
          file_path = "#{file_dir}#{class_name.singularize}.rb"
          return "Mailer already exist! #{file_path}" if File.exist?(file_path)

          File.open(file_path, "w") do |f|
            f.write(<<~TEXT)
              module Mutations
                module Mailers
                  class #{class_name.camelize}Mailer < BaseMutation
                    description "Mail を送信します。"
                    field :response, String, null: false

                    def resolve
                      # First, instantiate the Mailgun Client with your API key
                      mg_client = Mailgun::Client.new("YOUR-API-KEY")

                      # Define your message parameters
                      message_params = {
                        from: "postmaster@YOUR-DOMAIN",
                        to: "sending@to.mail.com",
                        subject: "SOULs Mailer test!",
                        text: "It is really easy to send a message!"
                      }

                      # Send your message through the client
                      mg_client.send_message("YOUR-sandbox.mailgun.org", message_params)
                      { response: "Job done!" }
                    rescue StandardError => e
                      GraphQL::ExecutionError.new(e.to_s)
                    end
                  end
              end
            TEXT
            puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
            file_path
          end
        end

        def sendgrid_mailer; end
      end
    end
  end
end
