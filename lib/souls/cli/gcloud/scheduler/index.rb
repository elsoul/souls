require "google/cloud/scheduler/v1"

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

      client = ::Google::Cloud::Scheduler::V1::CloudScheduler::Client.new
      request = ::Google::Cloud::Scheduler::V1::ListJobsRequest.new
      response = client.list_jobs(request)
      puts(response)
    end
  end
end
