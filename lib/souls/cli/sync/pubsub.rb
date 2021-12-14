module Souls
  class Sync < Thor
    desc "pubsub", "Sync Worker Jobs & Google Cloud Pubsub Subscriptions"
    def pubsub
      get_worker_endpoints
      Souls::Gcloud.new.config_set
      get_topics(workers: get_workers)
      Souls::Painter.sync("All Jobs with PubSub Subscription!")
    end

    private

    def get_worker_endpoints
      require("#{Souls.get_mother_path}/config/souls")
      worker_paths = Souls.configuration.workers
      worker_paths.each do |worker|
        endpoint = worker[:endpoint]
        unless endpoint.include?("https://")
          raise(StandardError, "You need to set endpoint.\nPlease Run:\n\n$ souls sync conf\n\n")
        end
      end
    end

    def get_topics(workers: {})
      project_id = Souls.configuration.project_id
      pubsub = Google::Cloud::Pubsub.new(project_id: project_id)
      topics = pubsub.topics

      topic_names =
        topics.map do |topic|
          topic.name.gsub("projects/#{project_id}/topics/", "")
        end

      souls_topics = topic_names.select { |n| n.include?("souls_") }

      souls_topics.each do |name|
        value = workers[name.to_sym] || 0
        workers[name.to_sym] = value - 1
      end

      workers.each do |key, value|
        if value == 1
          create_topic(topic_id: key.to_s)
          create_push_subscription(topic_id: key.to_s)
        end
        delete_topic(topic_id: key.to_s) if value == -1
        delete_subscription(topic_id: key.to_s) if value == -1
      end
      workers
    end

    def create_topic(topic_id: "mailer")
      project_id = Souls.configuration.project_id
      pubsub = Google::Cloud::Pubsub.new(project_id: project_id)
      topic = pubsub.create_topic(topic_id.to_s)
      puts("Topic #{topic.name} created.")
    end

    def delete_topic(topic_id: "mailer")
      project_id = Souls.configuration.project_id
      pubsub = Google::Cloud::Pubsub.new(project_id: project_id)
      topic = pubsub.topic(topic_id.to_s)
      topic.delete
      puts("Topic #{topic_id} deleted.")
    end

    def delete_subscription(topic_id: "mailer")
      project_id = Souls.configuration.project_id
      pubsub = Google::Cloud::Pubsub.new(project_id: project_id)
      subscription_id = "#{topic_id}_sub"
      subscription = pubsub.subscription(subscription_id)
      subscription.delete
    end

    def create_push_subscription(topic_id: "mailer")
      app = Souls.configuration.app
      require("#{Souls.get_mother_path}/config/souls")
      worker_name = topic_id.split("_")[1]

      subscription_id = "#{topic_id}_sub"
      endpoint = ""
      worker_paths = Souls.configuration.workers
      worker_paths.each do |worker|
        endpoint = worker[:endpoint] if worker[:name] == "souls-#{app}-#{worker_name}"
      end

      project_id = Souls.configuration.project_id
      pubsub = Google::Cloud::Pubsub.new(project_id: project_id)

      topic = pubsub.topic(topic_id)
      sub = topic.subscribe(subscription_id, endpoint: endpoint, deadline: 20)
      sub.expires_in = nil
      puts("Push subscription #{subscription_id} created.")
    end

    def get_workers
      require("#{Souls.get_mother_path}/config/souls")
      worker_paths = Souls.configuration.workers.map { |n| n[:name].split("-").last }
      response = {}
      Dir.chdir(Souls.get_mother_path.to_s) do
        worker_paths.each do |worker|
          workers =
            Dir["apps/#{worker}/app/graphql/queries/*.rb"].map do |file|
              file.gsub("apps/#{worker}/app/graphql/queries/", "").gsub(".rb", "")
            end
          workers.delete("base_query")
          workers.each do |file|
            response[:"souls_#{worker}_#{file}"] = 1
          end
        end
      end
      response
    end
  end
end
