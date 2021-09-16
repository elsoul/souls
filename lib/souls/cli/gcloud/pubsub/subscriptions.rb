module Souls
  class Pubsub < Thor
    desc "create_subscription", "Create Google Cloud PubSub Subscription"
    method_option :topic_name,
                  default: "send-user-mailer",
                  aliases: "--topic_name",
                  desc: "Google Cloud Pubsub Topic Name"
    method_option :endpoint,
                  default: "https:://test.com",
                  aliases: "--endpoint",
                  desc: "Google Cloud Pubsub Push Subscription Endpoint"
    def create_subscription
      project_id = Souls.configuration.project_id
      service_account = "#{Souls.configuration.app}@#{project_id}.iam.gserviceaccount.com"
      system(
        "gcloud pubsub subscriptions create #{options[:topic_name]}-sub \
            --topic #{options[:topic_name]} \
            --topic-project #{project_id} \
            --push-auth-service-account #{service_account} \
            --push-endpoint #{options[:endpoint]} \
            --expiration-period never
            "
      )
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "subscription_list", "Show Google Cloud Pubsub Subscription List"
    def subscription_list
      system("gcloud pubsub subscriptions list")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "update_subscription", "Update Google Cloud Pubsub Subscription Endpoint"
    method_option :topic_name,
                  default: "send-user-mailer",
                  aliases: "--topic_name",
                  desc: "Google Cloud Pubsub Topic Name"
    method_option :endpoint,
                  default: "https:://test.com",
                  aliases: "--endpoint",
                  desc: "Google Cloud Pubsub Push Subscription Endpoint"
    def update_subscription
      system("gcloud pubsub subscriptions update #{options[:topic_name]}-sub --push-endpoint #{options[:endpoint]} ")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
