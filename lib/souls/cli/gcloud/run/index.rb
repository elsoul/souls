module SOULs
  class CloudRun < Thor
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
