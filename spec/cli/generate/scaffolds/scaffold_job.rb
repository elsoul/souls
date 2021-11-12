module OutputScaffold
  def self.scaffold_job
    <<~JOB
module Queries
  class SomeJob < BaseQuery
    description ""
    type Types::SomeJobType, null: false

    def resolve
    end
  end
end
    JOB
  end

  def self.scaffold_job_mailer
    <<~JOBMAILER
module Queries
  class SomeJob < BaseQuery
    description ""
    type Types::SomeJobType, null: false

    def resolve
      # First, instantiate the Mailgun Client with your API key
      mg_client = ::Mailgun::Client.new("YOUR-API-KEY")

      # Define your message parameters
      message_params = {
        from: "postmaster@from.mail.com",
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
    JOBMAILER
  end
  
  def self.scaffold_job_type
    <<~JOBTYPE
module Types
  class SomeJobType < BaseObject
  end
end
    JOBTYPE
  end

  def self.scaffold_job_mailer_type
    <<~JOBMAILERTYPE
module Types
  class SomeJobType < BaseObject
    field :response, String, null: true
  end
end
    JOBMAILERTYPE
  end
  
  def self.base_query_type
    <<~BASEQUERY
module Types
  class QueryType < Types::BaseObject
    add_field(GraphQL::Types::Relay::NodeField)
    add_field(GraphQL::Types::Relay::NodesField)
  end
end
    BASEQUERY
  end
  
  def self.modified_query_type
    <<~MODIFIEDQUERY
module Types
  class QueryType < Types::BaseObject
    add_field(GraphQL::Types::Relay::NodeField)
    add_field(GraphQL::Types::Relay::NodesField)
    field :some_job, resolver: Queries::SomeJob
  end
end
    MODIFIEDQUERY
  end
end
