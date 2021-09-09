module Souls
  module Gcloud
    module Pubsub
      class << self
        def create_topic(topic_name: "send-user-mail")
          system("gcloud pubsub topics create #{topic_name}")
        end

        def topic_list
          system("gcloud pubsub topics list")
        end
      end
    end
  end
end
