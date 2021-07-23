module Souls
  module Gcloud
    class << self
      def create_pubsub_topic(topic_name: "send-user-mail")
        system("gcloud pubsub topics create #{topic_name}")
      end

      def create_pubsub_subscription(
        topic_name: "send-user-mail",
        project_id: "souls-app",
        service_account: "souls-app",
        endpoint: "https:://test.com"
      )
        system(
          "gcloud pubsub subscriptions create #{topic_name}-sub \
          --topic #{topic_name} \
          --topic-project #{project_id} \
          --push-auth-service-account #{service_account} \
          --push-endpoint #{endpoint} \
          --expiration-period never
           "
        )
      end
    end
  end
end
