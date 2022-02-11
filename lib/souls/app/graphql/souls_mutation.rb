module SOULs
  class SOULsMutation < GraphQL::Schema::RelayClassicMutation
    def souls_post(url:, payload: {}, content_type: "application/json")
      response = Faraday.post(url, payload.to_json, "Content-Type": content_type)
      response.body
    end

    def souls_worker_trigger(worker_name:, query_file_name:, args: {})
      query_file_name = query_file_name.gsub("_", "-")
      topic_name = "souls-#{worker_name}-#{query_file_name}"
      query = query_file_name.underscore.camelize(:lower)
      query_string = souls_make_graphql_query(query:, args:)
      case ENV["RACK_ENV"]
      when "production"
        souls_publish_pubsub_queue(topic_name:, message: query_string)
      when "development"
        puts(souls_post_to_dev(worker_name:, query_string:))
      end
    end

    def souls_check_user_permissions(user, obj, method)
      raise(StandardError, "Invalid or Missing Token") unless user

      policy_class = obj.class.name + "Policy"
      policy_clazz = policy_class.constantize.new(user, obj)
      permission = policy_clazz.public_send(method)
      raise(Pundit::NotAuthorizedError, "permission error!") unless permission
    end

    def souls_fb_auth(token: "")
      FirebaseIdToken::Certificates.request!
      user = FirebaseIdToken::Signature.verify(token)
      if user.blank?
        Retryable.retryable(tries: 20, on: ArgumentError) do
          user = FirebaseIdToken::Signature.verify(token)
          raise(ArgumentError, "Invalid or Missing Token") if user.blank?
        end
      end
      user
    end

    def souls_publish_pubsub_queue(topic_name: "send-mail-job", message: "text!")
      pubsub = Google::Cloud::Pubsub.new(project: ENV["SOULS_GCP_PROJECT_ID"])
      topic = pubsub.topic(topic_name)
      topic.publish(message)
    end

    def souls_make_graphql_query(query: "newCommentMailer", args: {})
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

    def souls_post_to_dev(worker_name: "", query_string: "")
      port = souls_get_worker(worker_name:)[0][:port]
      endpoint = SOULs.configuration.endpoint
      res = Net::HTTP.post_form(URI.parse("http://localhost:#{port}#{endpoint}"), { query: query_string })
      res.body
    end

    def souls_get_worker(worker_name: "")
      workers = SOULs.configuration.workers
      workers.filter { |n| n[:name] == worker_name }
    end

    def souls_auth_check(context)
      raise(GraphQL::ExecutionError, "You need to sign in!!") if context[:user].nil?
    end

    def production?
      ENV["RACK_ENV"] == "production"
    end

    def get_instance_id
      `curl http://metadata.google.internal/computeMetadata/v1/instance/id -H Metadata-Flavor:Google`
    end
  end
end
