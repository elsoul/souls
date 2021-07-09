module Souls
  module Gcloud
    class << self
      def enable_permissions
        system "gcloud services enable compute.googleapis.com"
        puts "Operating permission to compute.googleapis.com ..."
        system "gcloud services enable sqladmin.googleapis.com"
        puts "Operating permission to sqladmin.googleapis.com ..."
        system "gcloud services enable sql-component.googleapis.com"
        puts "Operating permission to sql-component.googleapis.com ..."
        system "gcloud services enable servicenetworking.googleapis.com"
        puts "Operating permission to servicenetworking.googleapis.com ..."
      end

      def create_network
        return "Error: Please Set Souls.configuration" if Souls.configuration.app.nil?
        network = Souls.configuration.app
        system "gcloud compute networks create #{network}"
      rescue StandardError => e
        raise StandardError, e
      end

      def create_firewall ip_range: "10.140.0.0/20"
        network = Souls.configuration.app
        system "gcloud compute firewall-rules create #{network} --network #{network} --allow tcp,udp,icmp --source-ranges #{ip_range}"
        system "gcloud compute firewall-rules create #{network}-ssh --network #{network} --allow tcp:22,tcp:3389,icmp"
      end

      def create_private_access
        network = Souls.configuration.app
        project_id = Souls.configuration.project_id
        system "gcloud compute addresses create #{network}-my-network \
        --global \
        --purpose=VPC_PEERING \
        --prefix-length=16 \
        --description='peering range for SOULs' \
        --network=#{network} \
        --project=#{project_id}"
      end

      def create_sql_instance
        project_id = Souls.configuration.project_id
        network = Souls.configuration.app
        system "gcloud --project=#{project_id} beta sql instances create #{network} --no-assign-ip --database-version=POSTGRES_13 --network #{network} --cpu=2 --memory=7680MB --region=asia-northeast1"
      end
    end
  end
end
