module SOULs
  class Pubsub < Thor
    desc "create_topic", "Create Google Cloud Pubsub Topic"
    def create_topic(topic_name)
      project = SOULs.configuration.project_id
      system("gcloud pubsub topics create #{topic_name} --project=#{project}")
    end

    desc "topic_list", "Show Google Cloud Topic List"
    def topic_list
      project = SOULs.configuration.project_id
      system("gcloud pubsub topics list --project=#{project}")
    end
  end
end
