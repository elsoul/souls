module Souls
  module Gcloud
    module Sql
      class << self
        def create_instance(instance_name: "", root_pass: "Postgre123!", zone: "asia-northeast1-b")
          instance_name = "#{Souls.configuration.app}-db" if instance_name.blank?
          current_ip = `curl inet-ip.info`
          system(
            "gcloud sql instances create #{instance_name} \
              --database-version=POSTGRES_13 --cpu=2 --memory=7680MB --zone=#{zone} \
              --assign-ip=#{current_ip} \
              --root-password='#{root_pass}' --database-flags cloudsql.iam_authentication=on"
          )
        end

        def patch_instance(instance_name: "")
          app_name = Souls.configuration.app
          instance_name = "#{Souls.configuration.app}-db" if instance_name.blank?
          project_id = Souls.configuration.project_id
          system("gcloud beta sql instances patch #{instance_name} --project=#{project_id} --network=#{app_name}")
        end

        def assign_ip
          current_ip = `curl inet-ip.info`
          project_id = Souls.configuration.project_id
          system("gcloud beta sql instances patch #{instance_name} --project=#{project_id} --assign-ip=#{current_ip}")
        end
      end
    end
  end
end
