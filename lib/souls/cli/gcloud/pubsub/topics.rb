module SOULs
  class Pubsub < Thor
    desc "create_topic", "Create Google Cloud Pubsub Topic"
    method_option :topic_name,
                  default: "send-user-mailer",
                  aliases: "--topic_name",
                  desc: "Google Cloud Pubsub Topic Name"
    def create_topic
      system("gcloud pubsub topics create #{options[:topic_name]}")
    end

    desc "topic_list", "Show Google Cloud Topic List"
    def topic_list
      system("gcloud pubsub topics list")
    end
  end
end
