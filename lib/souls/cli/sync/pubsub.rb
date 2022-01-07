module SOULs
  class Sync < Thor
    desc "pubsub", "Sync Worker Jobs & Google Cloud Pubsub Topics/Subscriptions"
    def pubsub
      project_id = SOULs.configuration.project_id
      worker_name = FileUtils.pwd.split("/").last

      unless worker_name.match(/^worker-(\d|\w)+(-)*(\d|\w)+$/)
        SOULs::Painter.error("You are at wrong dir!\nPlease go to worker-* dir!")
        return false
      end

      url = `gcloud run services list --platform=managed \
       --project=#{project_id} |grep souls-#{project_id}-#{worker_name}| awk '{print $4}'`.strip
      return false if url.blank?

      worker_file_names = get_workers_file_paths

      sync_pubsub_topics_and_subscriptions(worker_file_names: worker_file_names, worker_url: url)
      SOULs::Painter.sync("All Jobs with PubSub Subscription!")
    end

    private

    def sync_pubsub_topics_and_subscriptions(worker_url:, worker_file_names: {})
      project_id = SOULs.configuration.project_id
      pubsub = Google::Cloud::Pubsub.new(project_id: project_id)
      topics = pubsub.topics
      worker_name = FileUtils.pwd.split("/").last

      topic_names =
        topics.map do |topic|
          topic.name.gsub("projects/#{project_id}/topics/", "")
        end

      souls_topics = topic_names.select { |n| n.include?("souls-#{worker_name}") }

      souls_topics.each do |name|
        file_name = name.underscore
        value = worker_file_names[file_name.to_sym] || 0
        worker_file_names[file_name.to_sym] = value - 1
      end

      if worker_file_names.blank?
        return if souls_topics.blank?

        souls_topics.each do |topic_id|
          delete_topic(topic_id: topic_id)
          delete_subscription(topic_id: topic_id)
        end
      else
        worker_file_names.each do |key, value|
          topic_id = key.to_s.gsub("_", "-")
          if value == 1
            create_topic(topic_id: topic_id)
            create_push_subscription(worker_url: worker_url, topic_id: topic_id)
          end
          delete_topic(topic_id: topic_id) if value == -1
          delete_subscription(topic_id: topic_id) if value == -1
        end
      end
      worker_file_names
    end

    def create_topic(topic_id: "worker-mailer")
      project_id = SOULs.configuration.project_id
      pubsub = Google::Cloud::Pubsub.new(project_id: project_id)
      topic = pubsub.create_topic(topic_id.to_s)
      SOULs::Painter.success("Topic #{topic.name} created.")
    end

    def delete_topic(topic_id: "worker-mailer")
      project_id = SOULs.configuration.project_id
      pubsub = Google::Cloud::Pubsub.new(project_id: project_id)
      topic = pubsub.topic(topic_id.to_s)
      topic.delete
      SOULs::Painter.warning("Topic #{topic_id} deleted.", "✨")
    end

    def delete_subscription(topic_id: "worker-mailer")
      project_id = SOULs.configuration.project_id
      pubsub = Google::Cloud::Pubsub.new(project_id: project_id)
      subscription_id = "#{topic_id}-sub"
      subscription = pubsub.subscription(subscription_id)
      subscription.delete
    end

    def create_push_subscription(worker_url:, topic_id: "worker-mailer")
      souls_endpoint = SOULs.configuration.endpoint
      subscription_id = "#{topic_id}-sub"
      endpoint = "#{worker_url}#{souls_endpoint}"

      project_id = SOULs.configuration.project_id
      pubsub = Google::Cloud::Pubsub.new(project_id: project_id)

      topic = pubsub.topic(topic_id)
      sub = topic.subscribe(subscription_id, endpoint: endpoint, deadline: 20)
      sub.expires_in = nil
      SOULs::Painter.success("Push subscription #{subscription_id} created.")
    end

    def get_workers_file_paths
      worker_name = FileUtils.pwd.split("/").last
      response = {}
      workers =
        Dir["app/graphql/queries/*.rb"].map do |file|
          file.split("/").last.gsub(".rb", "")
        end
      workers.delete("base_query")
      workers.each do |file|
        response["souls_#{worker_name.underscore}_#{file}".to_sym] = 1
      end
      response
    end
  end
end
