module Souls
  class Compute < Thor
    desc "setup_vpc_nat", "Set Up VPC Cloud Nat"
    method_option :range, default: "10.124.0.0/28", aliases: "--range", desc: "GCP VPC Network IP Range"
    def setup_vpc_nat
      create_network
      create_firewall_tcp(range: options[:range])
      create_firewall_ssh
      create_subnet(range: options[:range])
      create_connector
      create_router
      create_external_ip
      create_nat
      nat_credit
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
      system("gcloud compute network list")
    end

    def nat_credit
      app_name = Souls.configuration.app
      line = Paint["====================================", :yellow]
      puts("\n")
      puts(line)
      txt2 = <<~TEXT
           _____ ____  __  ____#{'        '}
          / ___// __ \\/ / / / /   %{red1}
          \\__ \\/ / / / / / / /   %{red2}
         ___/ / /_/ / /_/ / /___%{red3}#{' '}
        /____/\\____/\\____/_____%{red4}#{'  '}
      TEXT
      red1 = ["_____", :red]
      red2 = ["/ ___/", :red]
      red3 = ["(__  )", :red]
      red4 = ["/____/", :red]
      ms = Paint % [txt2, :cyan, { red1: red1, red2: red2, red3: red3, red4: red4 }]
      puts(ms)
      puts(line)
      welcome = Paint["VPC Network is All Set!", :white]
      puts(welcome)
      puts(line)
      endroll = <<~TEXT

        Edit  `.github/workflow/worker.yml`

        Add these 2 options in \n`- name: Deploy to Cloud Run` step
        \n--vpc-connector=#{app_name}-connector \
        \n--vpc-egress=all \

      TEXT
      cd = Paint[endroll, :white]
      puts(cd)
      puts(line)
    end
  end
end
