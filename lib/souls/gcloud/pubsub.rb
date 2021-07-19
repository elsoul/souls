module Souls
  module Gcloud
    class << self
      def create_pubsub_topic(args)
        system("gcloud pubsub topics create #{args[:topic_name]}")
      end

      def create_pubsub_subscription(args)
        system(
          "gcloud pubsub subscriptions create #{args[:topic_name]}-sub \
          --topic #{args[:topic_name]} \
          --topic-project #{args[:project_id]} \
          --push-auth-service-account #{args[:service_account]} \
          --push-endpoint #{args[:endpoint]} \
          --expiration-period never
           "
        )
      end
    end
  end
end
