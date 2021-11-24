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
      Queries::BaseQuery.all_schedules.each do |k, v|
        system(
          "gcloud scheduler jobs create pubsub #{k}
              --schedule #{v}
              --topic=#{k}
              --message-body=\"#{k}\""
        )
      end
    end
  end
end
