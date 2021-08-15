module Souls
  module Worker
    module Generate
      class << self
        def mailer(class_name: "mailer", option: "")
          puts(option)
          if option.to_sym == :sendgrid
            sendgrid_mailer(class_name: class_name)
          else
            mailgun_mailer(class_name: class_name)
          end
        end

        private

        def mailgun_mailer(class_name: "mailer")
          file_dir = "./app/graphql/mutations/mailers/"
          FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
          file_path = "#{file_dir}#{class_name.singularize}_mailer.rb"
          raise(StandardError, "Mailer already exist! #{file_path}") if File.exist?(file_path)

          File.open(file_path, "w") do |f|
            f.write(<<~TEXT)
              module Mutations
                module Mailers
                  class #{class_name.camelize}Mailer < BaseMutation
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

        def sendgrid_mailer(class_name: "mailer")
          p("Coming Soon..")
        end
      end
    end
  end
end
