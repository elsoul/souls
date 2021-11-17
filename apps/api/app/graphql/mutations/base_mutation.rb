module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    def fb_auth(token:)
      FirebaseIdToken::Certificates.request!
      sleep(3) if ENV["RACK_ENV"] == "development"
      @payload = FirebaseIdToken::Signature.verify(token)
      raise(ArgumentError, "Invalid or Missing Token") if @payload.blank?

      @payload
    end

    def publish_pubsub_queue(topic_name: "send-mail-job", message: "text!")
      pubsub = Google::Cloud::Pubsub.new(project: ENV["SOULS_GCP_PROJECT_ID"])
      topic = pubsub.topic(topic_name)
      topic.publish(message)
    end

    def make_graphql_query(query: "newCommentMailer", args: {})
      if args.blank?
        query_string = %(query { #{query.to_s.underscore.camelize(:lower)} { response } })
      else
        inputs = ""
        args.each do |key, value|
          inputs +=
            if value.instance_of?(String)
              "#{key.to_s.underscore.camelize(:lower)}: \"#{value}\" "
            else
              "#{key.to_s.underscore.camelize(:lower)}: #{value} "
            end
        end
        query_string = %(query { #{query.to_s.underscore.camelize(:lower)}(#{inputs}) { response } })
      end
      query_string
    end

    def post_to_dev(worker_name: "", query_string: "")
      app = Souls.configuration.app
      port = get_worker(worker_name: "souls-#{app}-#{worker_name}")[0][:port]
      endpoint = Souls.configuration.endpoint
      res = Net::HTTP.post_form(URI.parse("http://localhost:#{port}#{endpoint}"), { query: query_string })
      res.body
    end

    def get_worker(worker_name: "")
      workers = Souls.configuration.workers
      workers.filter { |n| n[:name] == worker_name }
    end

    def auth_check(context)
      raise(GraphQL::ExecutionError, "You need to sign in!!") if context[:user].nil?
    end

    def get_token(token)
      JsonWebToken.decode(token)
    end

    def production?
      ENV["RACK_ENV"] == "production"
    end

    def get_instance_id
      `curl http://metadata.google.internal/computeMetadata/v1/instance/id -H Metadata-Flavor:Google`
    end
  end
end
