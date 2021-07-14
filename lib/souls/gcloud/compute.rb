module Souls
  module Gcloud
    def self.auth_login
      project_id = Souls.configuration.project_id
      system("gcloud config set project #{project_id}")
      system("gcloud auth login")
    end

    def self.enable_permissions
      system("gcloud services enable compute.googleapis.com")
      puts("Operating permission to compute.googleapis.com ...")
      system("gcloud services enable iam.googleapis.com")
      puts("Operating permission to iam.googleapis.com ...")
      system("gcloud services enable dns.googleapis.com")
      puts("Operating permission to dns.googleapis.com ...")
      system("gcloud services enable sqladmin.googleapis.com")
      puts("Operating permission to sqladmin.googleapis.com ...")
      system("gcloud services enable sql-component.googleapis.com")
      puts("Operating permission to sql-component.googleapis.com ...")
      system("gcloud services enable servicenetworking.googleapis.com")
      puts("Operating permission to servicenetworking.googleapis.com ...")
      system("gcloud services enable containerregistry.googleapis.com")
      puts("Operating permission to containerregistry.googleapis.com")
      system("gcloud services enable run.googleapis.com")
      puts("Operating permission to run.googleapis.com")
    end

    def self.create_network
      return "Error: Please Set Souls.configuration" if Souls.configuration.app.nil?

      network = Souls.configuration.app
      system("gcloud compute networks create #{network}")
    rescue StandardError => e
      raise(StandardError, e)
    end

    def self.create_firewall(ip_range: "10.140.0.0/20")
      network = Souls.configuration.app
      system(
        "gcloud compute firewall-rules create #{network}
      --network #{network}
      --allow tcp,udp,icmp
      --source-ranges #{ip_range}"
      )
      system("gcloud compute firewall-rules create #{network}-ssh --network #{network} --allow tcp:22,tcp:3389,icmp")
    end

    def self.create_private_access
      network = Souls.configuration.app
      project_id = Souls.configuration.project_id
      system(
        "gcloud compute addresses create #{network}-my-network \
      --global \
      --purpose=VPC_PEERING \
      --prefix-length=16 \
      --description='peering range for SOULs' \
      --network=#{network} \
      --project=#{project_id}"
      )
    end

    def self.create_sql_instance(root_pass: "Postgre123!", zone: "asia-northeast1-b")
      app = "#{Souls.configuration.app}-db"
      system(
        "gcloud sql instances create #{app}
        --database-version=POSTGRES_13 --cpu=2 --memory=7680MB --zone=#{zone}
        --root-password='#{root_pass}' --database-flags cloudsql.iam_authentication=on"
      )
    end
  end
end
