module Souls
  module Gcloud
    module Compute
      class << self
        def setup_vpc_nat(app_name: "", region: "asia-northeast1", range: "10.124.0.0/28")
          create_network(app_name: app_name)
          create_firewall_tcp(app_name: app_name, range: range)
          create_firewall_ssh(app_name: app_name, range: range)
          create_subnet(app_name: app_name, region: region, range: range)
          create_connector(app_name: app_name, region: region)
          create_external_ip(app_name: app_name, region: region)
          create_nat(app_name: app_name, region: region)
        end

        def create_network(app_name: "")
          app_name = Souls.configuration.app if app_name.blank?
          system("gcloud compute networks create #{app_name}")
        end

        def create_firewall_tcp(app_name: "", range: "10.124.0.0/28")
          app_name = Souls.configuration.app if app_name.blank?
          system(
            "gcloud compute firewall-rules create #{app_name} \
                  --network #{app_name} --allow tcp,udp,icmp --source-ranges #{range}"
          )
        end

        def create_firewall_ssh(app_name: "")
          app_name = Souls.configuration.app if app_name.blank?
          system(
            "gcloud compute firewall-rules create #{app_name}-ssh --network #{app_name} \
            --allow tcp:22,tcp:3389,icmp"
          )
        end

        def create_subnet(app_name: "", region: "asia-northeast1", range: "10.124.0.0/28")
          app_name = Souls.configuration.app if app_name.blank?
          system(
            "gcloud compute networks subnets create #{app_name}-subnet \
            --range=#{range} --network=#{app_name} --region=#{region}"
          )
        end

        def create_connector(app_name: "", region: "asia-northeast1")
          app_name = Souls.configuration.app if app_name.blank?
          project_id = Souls.configuration.app if project_id.blank?
          system(
            "gcloud compute networks vpc-access connectors create #{app_name}-connector \
              --region=#{region} \
              --subnet-project=#{project_id} \
              --subnet=#{app_name}-subnet"
          )
        end

        def create_external_ip(app_name: "", region: "asia-northeast1")
          app_name = Souls.configuration.app if app_name.blank?
          system("gcloud compute addresses create #{app_name}-worker-ip --region=#{region}")
        end

        def create_nat(app_name: "", region: "asia-northeast1")
          app_name = Souls.configuration.app if app_name.blank?
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
      end
    end
  end
end
