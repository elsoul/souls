module Souls
  class CloudRun < Thor
    desc "awake", "Set Ping Every 15min by Google Cloud Scheduler"
    method_option :url, default: "https://souls.souls.nl", aliases: "--url", desc: "Set URL"
    def awake
      app_name = Souls.configuration.app
      system(
        "gcloud scheduler jobs create http #{app_name}-awake
            --schedule '0,10,20,30,40,50 * * * *' --uri #{url} --http-method GET"
      )
    end

    desc "list", "Show Google Cloud Run List"
    def list
      system("gcloud run services list --platform managed")
    end

    desc "get_endpoint", "Show Worker's Endpoint"
    def get_endpoint(worker_name: "")
      `gcloud run services list  --platform managed | grep #{worker_name} | awk '{print $4}'`
    end
  end
end
