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
          project_id = Souls.configuration.project_id if project_id.blank?
          service_account = "#{Souls.configuration.app}@#{project_id}.iam.gserviceaccount.com" if service_account.blank?
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

        def subscription_list
          system("gcloud pubsub subscriptions list")
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
