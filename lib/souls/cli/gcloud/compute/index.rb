module Souls
  class Compute < Thor
    desc "setup_vpc_nat", "Set Up VPC Cloud Nat"
    method_option :range, default: "10.124.0.0/28", aliases: "--range", desc: "GCP VPC Network IP Range"
    def setup_vpc_nat
      puts(Paint["Initializing NAT Setup This process might take about 5 min...", :yellow])
      create_network
      create_firewall_tcp(range: options[:range])
      create_firewall_ssh
      create_subnet(range: options[:range])
      create_connector
      create_router
      create_external_ip
      create_nat
      Souls::Sql.new.invoke(:setup_private_ip)
      update_workflows
      puts(Paint["Cloud NAT is All Set!", :green])
      true
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    private

    def create_network
      app_name = Souls.configuration.app
      system("gcloud compute networks create #{app_name}")
    end

    def create_firewall_tcp(range: "10.124.0.0/28")
      app_name = Souls.configuration.app
      system(
        "gcloud compute firewall-rules create #{app_name} \
                  --network #{app_name} --allow tcp,udp,icmp --source-ranges #{range}"
      )
    end

    def create_firewall_ssh
      app_name = Souls.configuration.app
      system(
        "gcloud compute firewall-rules create #{app_name}-ssh --network #{app_name} \
            --allow tcp:22,tcp:3389,icmp"
      )
    end

    def create_subnet(range: "10.124.0.0/28")
      app_name = Souls.configuration.app
      region = Souls.configuration.region
      system(
        "gcloud compute networks subnets create #{app_name}-subnet \
            --range=#{range} --network=#{app_name} --region=#{region}"
      )
    end

    def create_connector
      app_name = Souls.configuration.app
      project_id = Souls.configuration.project_id
      region = Souls.configuration.region
      system(
        "gcloud compute networks vpc-access connectors create #{app_name}-connector \
              --region=#{region} \
              --subnet-project=#{project_id} \
              --subnet=#{app_name}-subnet"
      )
    end

    def create_router
      app_name = Souls.configuration.app
      region = Souls.configuration.region
      system("gcloud compute routers create #{app_name}-router --network=#{app_name} --region=#{region}")
    end

    def create_external_ip
      app_name = Souls.configuration.app
      region = Souls.configuration.region
      system("gcloud compute addresses create #{app_name}-worker-ip --region=#{region}")
    end

    def create_nat
      app_name = Souls.configuration.app
      region = Souls.configuration.region
      system(
        "gcloud compute routers nats create #{app_name}-worker-nat \
                  --router=#{app_name}-router \
                  --region=#{region} \
                  --nat-custom-subnet-ip-ranges=#{app_name}-subnet \
                  --nat-external-ip-pool=#{app_name}-worker-ip"
      )
    end

    def network_list
      system("gcloud compute networks list")
    end

    def update_workflows
      app_name = Souls.configuration.app
      Dir.chdir(Souls.get_mother_path.to_s) do
        api_workflow_path = ".github/workflows/api.yml"
        worker_workflow_paths = Dir[".github/workflows/*.yml"]
        worker_workflow_paths.delete(api_workflow_path)
        File.open(api_workflow_path, "a") do |line|
          line.write(" \\ \n            --vpc-connector=#{app_name}-connector")
        end
        puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [api_workflow_path.to_s, :white] }])
        worker_workflow_paths.each do |file_path|
          File.open(file_path, "a") do |line|
            line.write(" \\             --vpc-connector=#{app_name}-connector \\")
            line.write("\n            --vpc-egress=all")
          end
          puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
        end
      end
    end
  end
end
