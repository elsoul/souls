module Souls
  class CloudScheduler < Thor
    desc "awake", "Set Ping Every 15min by Google Cloud Scheduler"
    method_option :url, default: "https://souls.souls.nl", aliases: "--url", desc: "Set URL"
    def awake
      app_name = Souls.configuration.app
      system(
        "gcloud scheduler jobs create http #{app_name}-awake
            --schedule '0,10,20,30,40,50 * * * *' --uri #{options[:url]} --http-method GET"
      )
    end

    desc "sync_schedules", "Collect schedules from queries and sync with GCloud"
    def sync_schedules
      require("./app")
      Souls::Gcloud.new.config_set
      project_id = Souls.configuration.project_id
      Queries::BaseQuery.all_schedules.each do |k, v|
        worker_name = FileUtils.pwd.split("/").last
        job_name = "#{worker_name}_#{k.to_s.underscore}"
        system("gcloud scheduler jobs delete #{job_name} -q >/dev/null 2>&1")
        system(
          <<~COMMAND)
            gcloud scheduler jobs create pubsub #{job_name} --project=#{project_id} --quiet --schedule="#{v}" --topic="#{k}" --attributes="" --message-body="#{k}"
          COMMAND
      end
    end
  end
end
