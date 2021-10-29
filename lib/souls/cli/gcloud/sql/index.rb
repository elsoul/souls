module Souls
  class Sql < Thor
    desc "create_instance", "Create Google Cloud SQL - PostgreSQL13"
    method_option :region, default: "", aliases: "--region", desc: "Google Cloud Platform Region"
    method_option :root_password, default: "", aliases: "--root-password", desc: "Set Cloud SQL Root Password"
    method_option :mysql, type: :boolean, default: false, aliases: "--mysql", desc: "Set Cloud SQL Type to MySQL"
    def create_instance
      instance_name = "souls-#{Souls.configuration.app}-db" if instance_name.blank?
      region = Souls.configuration.region if options[:region].blank?
      db_type = options[:mysql] ? "MYSQL_8_0" : "POSTGRES_13"

      zone = "#{region}-b"
      system(
        "gcloud sql instances create #{instance_name} \
              --database-version=#{db_type} --cpu=2 --memory=7680MB --zone=#{zone} \
              --root-password='#{options[:root_password]}' --database-flags cloudsql.iam_authentication=on"
      )
      Dir.chdir(Souls.get_api_path.to_s) do
        file_path = ".env"
        lines = File.readlines(".env")
        lines[0] = "DB_HOST=#{get_sql_ip.strip}\n"
        lines[1] = "DB_PW=#{options[:root_password]}\n"
        lines[2] = "DB_USER=postgres\n"
        File.open(file_path, "w") { |f| f.write(lines.join) }
      end
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "list", "Show Cloud SQL Instances List"
    def list
      system("gcloud sql instances list")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "setup_private_ip", "Enable Private IP"
    def setup_private_ip
      create_ip_range
      create_vpc_connector
      assign_network
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "assign_network", "Assign Network"
    def assign_network
      app_name = Souls.configuration.app
      instance_name = "#{Souls.configuration.app}-db"
      project_id = Souls.configuration.project_id
      system("gcloud beta sql instances patch #{instance_name} --project=#{project_id} --network=#{app_name}")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "create_ip_range", "Create VPC Adress Range"
    def create_ip_range
      app_name = Souls.configuration.app
      project_id = Souls.configuration.project_id
      system(
        "
            gcloud compute addresses create #{app_name}-ip-range \
              --global \
              --purpose=VPC_PEERING \
              --prefix-length=16 \
              --description='peering range for SOULs' \
              --network=#{app_name} \
              --project=#{project_id}"
      )
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "create_vpc_connector", "Create VPC-PEERING Connect"
    def create_vpc_connector
      app_name = Souls.configuration.app
      project_id = Souls.configuration.project_id
      system(
        "
            gcloud services vpc-peerings connect \
              --service=servicenetworking.googleapis.com \
              --ranges=#{app_name}-ip-range \
              --network=#{app_name} \
              --project=#{project_id}
            "
      )
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "assgin_ip", "Add Current Grobal IP to White List"
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
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    private

    def get_sql_ip
      `gcloud sql instances list | grep james | awk '{print $5}'`
    end
  end
end
