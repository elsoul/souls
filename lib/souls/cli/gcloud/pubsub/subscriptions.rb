module Souls
  module Gcloud
    module Pubsub
      class << self
        def create_subscription(
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

        def update_subscription(
          topic_name: "send-user-mail",
          endpoint: "https:://test.com"
        )
          system("gcloud pubsub subscriptions update #{topic_name}-sub --push-endpoint #{endpoint} ")
        end
      end
    end
  end
end
