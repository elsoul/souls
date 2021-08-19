module Souls
  module Gcloud
    module Run
      class << self
        def awake(app_name: "souls-app", url: "")
          system(
            "gcloud scheduler jobs create http #{app_name}-awake
            --schedule '0,10,20,30,40,50 * * * *' --uri #{url} --http-method GET"
          )
        end

        def list(project_id: "souls-app")
          system("gcloud run services list --project #{project_id}")
        end
      end
    end
  end
end
