module Souls
  class Pubsub < Thor
    desc "create_topic", "Create Google Cloud Pubsub Topic"
    method_option :topic_name,
                  default: "send-user-mailer",
                  aliases: "--topic_name",
                  desc: "Google Cloud Pubsub Topic Name"
    def create_topic
      system("gcloud pubsub topics create #{options[:topic_name]}")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "topic_list", "Show Google Cloud Topic List"
    def topic_list
      system("gcloud pubsub topics list")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
