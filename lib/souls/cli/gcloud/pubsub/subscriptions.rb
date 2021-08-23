module Souls
  module Gcloud
    module Pubsub
      class << self
        def create_subscription(
          topic_name: "send-user-mail",
          project_id: "",
          service_account: "",
          endpoint: "https:://test.com"
        )
          service_account = Souls.configuration.app if service_account.blank?
          project_id = Souls.configuration.project_id if project_id.blank?
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
