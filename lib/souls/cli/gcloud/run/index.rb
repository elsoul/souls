module SOULs
  class CloudRun < Thor
    desc "list", "Show Google Cloud Run List"
    def list
      system("gcloud run services list --platform managed")
    end

    desc "get_endpoint [service_name]", "Show Worker's Endpoint"
    def get_endpoint(service_name)
      `gcloud run services list  --platform managed | grep #{service_name} | awk '{print $4}'`
    end
  end
end
