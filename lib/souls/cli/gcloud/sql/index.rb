module Souls
  module Gcloud
    module Sql
      class << self
        def create_instance(instance_name: "", root_pass: "Postgre123!", zone: "asia-northeast1-b")
          instance_name = "#{Souls.configuration.app}-db" if instance_name.blank?
          system(
            "gcloud sql instances create #{instance_name} \
              --database-version=POSTGRES_13 --cpu=2 --memory=7680MB --zone=#{zone} \
              --root-password='#{root_pass}' --database-flags cloudsql.iam_authentication=on"
          )
        end

        def patch_instance(instance_name: "")
          app_name = Souls.configuration.app
          instance_name = "#{Souls.configuration.app}-db" if instance_name.blank?
          project_id = Souls.configuration.project_id
          system(
            "
            gcloud beta sql instances patch #{instance_name} \
            --project=#{project_id} \
            --network=#{app_name} \
            --no-assign-ip"
          )
        end

        def assign_ip(instance_name: "", ip: "")
          ip = `curl inet-ip.info` if ip.blank?
          project_id = Souls.configuration.project_id
          instance_name = "#{Souls.configuration.app}-db" if instance_name.blank?
          system(
            "
            gcloud beta sql instances patch #{instance_name} \
              --project=#{project_id} \
              --assign-ip \
              --authorized-networks=#{ip} \
              --quiet
            "
          )
        end
      end
    end
  end
end
