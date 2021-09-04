module Mutations
  module Mailers
    class NewCommentMailer < BaseMutation
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
