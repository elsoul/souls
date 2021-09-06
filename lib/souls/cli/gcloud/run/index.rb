module Souls
  module Gcloud
    module Run
      class << self
        def awake(app_name: "", url: "")
          app_name = Souls.configuration.app if app_name.blank?
          system(
            "gcloud scheduler jobs create http #{app_name}-awake
            --schedule '0,10,20,30,40,50 * * * *' --uri #{url} --http-method GET"
          )
        end

        def list(project_id: "")
          project_id = Souls.configuration.project_id if project_id.blank?
          system("gcloud run services list --project #{project_id}")
        end

        def get_endpoint(worker_name: "")
          `gcloud run services list | grep #{worker_name} | awk '{print $4}'`
        end
      end
    end
  end
end
