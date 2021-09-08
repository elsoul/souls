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

        def setup_private_ip(instance_name: "")
          app_name = Souls.configuration.app
          instance_name = "#{Souls.configuration.app}-db" if instance_name.blank?
          project_id = Souls.configuration.project_id
          create_ip_range
          create_vpc_connector
          system("gcloud beta sql instances patch #{instance_name} --project=#{project_id} --network=#{app_name}")
        end

        def create_ip_range
          app_name = Souls.configuration.app
          system(
            "
            gcloud compute addresses create #{app_name}-ip-range \
              --global \
              --purpose=VPC_PEERING \
              --prefix-length=16 \
              --description='peering range for SOULs' \
              --network=#{app_name} \
              --project=#{app_name}"
          )
        end

        def create_vpc_connector
          app_name = Souls.configuration.app
          system(
            "
            gcloud services vpc-peerings connect \
              --service=servicenetworking.googleapis.com \
              --ranges=#{app_name}-ip-range \
              --network=#{app_name} \
              --project=#{app_name}
            "
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
