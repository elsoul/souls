module SOULs
  class Sql < Thor
    desc "create_instance", "Create Google Cloud SQL - PostgreSQL13"
    method_option :region, default: "", aliases: "--region", desc: "Google Cloud Platform Region"
    method_option :mysql, type: :boolean, default: false, aliases: "--mysql", desc: "Set Cloud SQL Type to MySQL"
    def create_instance
      prompt = TTY::Prompt.new
      password = prompt.mask("Set DB PassWord:")
      project_id = SOULs.configuration.project_id
      instance_name = SOULs.configuration.instance_name
      region = SOULs.configuration.region if options[:region].blank?
      db_type = options[:mysql] ? "MYSQL_8_0" : "POSTGRES_14"

      zone = "#{region}-b"
      system("gcloud config set project #{project_id} >/dev/null 2>&1")
      system(
        "gcloud sql instances create #{instance_name} \
                --database-version=#{db_type} --cpu=1 --memory=4096MB --zone=#{zone} \
                --root-password='#{password}' --database-flags cloudsql.iam_authentication=on"
      )
      SOULs::Sql.new.env(password:)
      SOULs::Github.new.secret_set
      SOULs::Painter.success("Cloud SQL #{instance_name} is successfully created! You can push to deploy!")
      true
    end

    desc "stop", "Stop Cloud SQL Instance"
    def stop
      project_id = SOULs.configuration.project_id
      instance_name = SOULs.configuration.instance_name
      system("gcloud sql instances patch #{instance_name} --project=#{project_id} --activation-policy=NEVER")
      SOULs::Painter.warning("Cloud SQL #{instance_name} is stopped!")
    end

    desc "restart", "Restart Cloud SQL Instance"
    def restart
      project_id = SOULs.configuration.project_id
      instance_name = SOULs.configuration.instance_name
      system("gcloud sql instances restart #{instance_name} --project=#{project_id}")
      SOULs::Painter.success("Cloud SQL #{instance_name} is restarted!")
    end

    desc "delete", "Delete Cloud SQL Instance"
    def delete
      project_id = SOULs.configuration.project_id
      instance_name = SOULs.configuration.instance_name
      system("gcloud sql instances delete #{instance_name} --project=#{project_id}")
      SOULs::Painter.warning("Cloud SQL #{instance_name} is deleted!", "✨")
    end

    desc "env", "Generate .env.production file to deploy"
    def env(password: "Password")
      require(SOULs.get_mother_path.to_s + "/config/souls")
      project_id = SOULs.configuration.project_id
      instance_name = SOULs.configuration.instance_name
      region = SOULs.configuration.region
      app_name = SOULs.configuration.app
      prompt = TTY::Prompt.new
      db_password = password == "Password" ? prompt.mask("Set DB PassWord:") : password
      instance_ip = `gcloud sql instances list --project=#{project_id} | grep #{instance_name} | awk '{print $5}'`.strip
      Dir.chdir(SOULs.get_api_path.to_s) do
        file_path = ".env"
        File.open(file_path, "w") do |line|
          line.write(<<~TEXT)
            RUBY_YJIT_ENABLE=1
            GOOGLE_AUTH_SUPPRESS_CREDENTIALS_WARNINGS=1
            SOULS_DB_HOST=#{instance_ip}
            SOULS_DB_PW=#{db_password}
            SOULS_DB_USER=postgres
            SOULS_GCP_PROJECT_ID=#{project_id}
            SOULS_FB_PROJECT_ID=#{project_id}
            SOULS_SECRET_KEY_BASE='#{SecureRandom.base64(64)}'
            TZ="#{region_to_timezone(region:)}"
          TEXT
        end
        SOULs::Painter.create_file(file_path)
      end
      Dir.chdir(SOULs.get_mother_path.to_s) do
        file_path = ".env.production"
        File.open(file_path, "w") do |line|
          line.write(<<~TEXT)
            RUBY_YJIT_ENABLE=1
            SOULS_DB_HOST="/cloudsql/#{project_id}:#{region}:#{instance_name}"
            SOULS_DB_PW=#{db_password}
            SOULS_DB_USER=postgres
            SOULS_APP_NAME=#{app_name}
            SOULS_GCP_PROJECT_ID=#{project_id}
            SOULS_FB_PROJECT_ID=#{project_id}
            SOULS_GCP_REGION=#{region}
            SOULS_GCLOUDSQL_INSTANCE="#{project_id}:#{region}:#{instance_name}"
            SOULS_SECRET_KEY_BASE='#{SecureRandom.base64(64)}'
            TZ="#{region_to_timezone(region:)}"
          TEXT
        end
        SOULs::Painter.create_file(file_path)
      end
    end

    desc "list", "Show Cloud SQL Instances List"
    def list
      system("gcloud sql instances list")
    end

    desc "setup_private_ip", "Enable Private IP"
    def setup_private_ip
      create_ip_range
      create_vpc_connector
      assign_network
    end

    desc "assign_network", "Assign Network"
    def assign_network
      app_name = SOULs.configuration.app
      instance_name = SOULs.configuration.instance_name
      project_id = SOULs.configuration.project_id
      system("gcloud beta sql instances patch #{instance_name} --project=#{project_id} --network=#{app_name}")
    end

    desc "create_ip_range", "Create VPC Adress Range"
    def create_ip_range
      app_name = SOULs.configuration.app
      project_id = SOULs.configuration.project_id
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
    end

    desc "create_vpc_connector", "Create VPC-PEERING Connect"
    def create_vpc_connector
      app_name = SOULs.configuration.app
      project_id = SOULs.configuration.project_id
      system(
        "
          gcloud services vpc-peerings connect \
            --service=servicenetworking.googleapis.com \
            --ranges=#{app_name}-ip-range \
            --network=#{app_name} \
            --project=#{project_id}
      "
      )
    end

    desc "assgin_ip", "Add Current Grobal IP to White List"
    method_option :ip, default: "", aliases: "--ip", desc: "Adding IP to Google Cloud SQL White List: e.g.'11.11.1.1'"
    def assign_ip
      require(SOULs.get_mother_path.to_s + "/config/souls")
      project_id = SOULs.configuration.project_id
      instance_name = SOULs.configuration.instance_name
      ips = []
      ip =
        if options[:ip].blank?
          `curl inet-ip.info`.strip
        else
          options[:ip].strip
        end
      ips << ip
      cloud_sql = JSON.parse(
        `curl -X GET \
        -H "Authorization: Bearer "$(gcloud auth print-access-token) \
        "https://sqladmin.googleapis.com/v1/projects/#{project_id}/instances/#{instance_name}?fields=settings"`
      )
      begin
        cloud_sql["settings"]["ipConfiguration"]["authorizedNetworks"].blank?
        white_ips =
          cloud_sql["settings"]["ipConfiguration"]["authorizedNetworks"].map do |sql_ips|
            sql_ips["value"]
          end
        ips = (ips + white_ips).uniq
      rescue StandardError => e
        puts(e)
      end
      ips = ips.join(",")
      Whirly.start(spinner: "clock", interval: 420, stop: "🎉") do
        system(
          "
            gcloud sql instances patch #{instance_name} \
              --project=#{project_id} \
              --assign-ip \
              --authorized-networks=#{ips} \
              --quiet
            "
        )
        Whirly.status = Paint["Your IP is successfully added!", :green]
      end
      true
    end

    private

    def region_to_timezone(region: "asia-northeast1")
      if region.include?("asia")
        "Asia/Tokyo"
      elsif region.include?("europe")
        "Europe/Amsterdam"
      else
        "America/Los_Angeles"
      end
    end
  end
end
