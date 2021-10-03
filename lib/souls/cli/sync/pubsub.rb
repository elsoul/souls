module Souls
  class Sync < Thor
    desc "pubsub", "Sync Worker Jobs & Google Cloud Pubsub Subscriptions"
    def pubsub
      Souls::Gcloud.new.config_set
      get_topics(workers: get_workers)
      puts(Paint["All Jobs Synced with PubSub Subscription!", :green])
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    private

    def get_topics(workers: {})
      app_name = Souls.configuration.app
      project_id = Souls.configuration.project_id
      pubsub = Google::Cloud::Pubsub.new(project_id: ENV["PROJECT_ID"])
      topics = pubsub.topics

      topic_names =
        topics.map do |topic|
          topic.name.gsub("projects/#{project_id}/topics/", "")
        end

      souls_topics = topic_names.select { |n| n.include?("souls_#{app_name}_") }

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
      end
      workers
    end

    def create_topic(topic_id: "mailer")
      app_name = Souls.configuration.app
      pubsub = Google::Cloud::Pubsub.new(project_id: ENV["PROJECT_ID"])
      topic_name = "souls_#{app_name}_#{topic_id}"
      topic = pubsub.create_topic(topic_name.to_s)
      puts("Topic #{topic.name} created.")
    end

    def delete_topic(topic_id: "mailer")
      app_name = Souls.configuration.app
      pubsub = Google::Cloud::Pubsub.new(project_id: ENV["PROJECT_ID"])
      topic_name = "souls_#{app_name}_#{topic_id}"
      topic = pubsub.topic(topic_name.to_s)
      topic.delete
      puts("Topic #{topic_name} deleted.")
    end

    def create_push_subscription(topic_id: "mailer")
      require("#{Souls.get_mother_path}/config/souls")
      app_name = Souls.configuration.app
      topic_name = "souls_#{app_name}_#{topic_id}"
      worker_name = topic_id.split("_")[0]

      subscription_id = "#{topic_name}_sub"
      endpoint = ""
      worker_paths = Souls.configuration.workers
      worker_paths.each do |worker|
        endpoint = worker[:endpoint] if worker[:name] == worker_name
      end

      pubsub = Google::Cloud::Pubsub.new(project_id: ENV["PROJECT_ID"])

      topic = pubsub.topic(topic_name)
      sub = topic.subscribe(subscription_id, endpoint: endpoint, deadline: 20)
      sub.expires_in = nil
      puts("Push subscription #{subscription_id} created.")
    end

    def get_workers
      require("#{Souls.get_mother_path}/config/souls")
      worker_paths = Souls.configuration.workers.map { |n| n[:name] }
      response = {}
      Dir.chdir(Souls.get_mother_path.to_s) do
        worker_paths.each do |worker|
          mailers =
            Dir["apps/#{worker}/app/graphql/mutations/mailers/*.rb"].map do |file|
              file.gsub("apps/#{worker}/app/graphql/mutations/mailers/", "").gsub(".rb", "")
            end

          workers =
            Dir["apps/#{worker}/app/graphql/mutations/*.rb"].map do |file|
              file.gsub("apps/#{worker}/app/graphql/mutations/", "").gsub(".rb", "")
            end
          workers.delete("base_mutation")
          local_files = mailers + workers
          local_files.each do |file|
            response[:"#{worker}_#{file}"] = 1
          end
        end
      end
      response
    end
  end
end
