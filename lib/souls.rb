require "souls/version"
require "souls/init"

module Souls
  class Error < StandardError; end
    class << self
      attr_accessor :configuration

      def delete_forwarding_rule forwarding_rule_name: "grpc-gke-forwarding-rule"
        system "gcloud compute -q forwarding-rules delete #{forwarding_rule_name} --global"
      end

      def create_forwarding_rule forwarding_rule_name: "grpc-gke-forwarding-rule", proxy_name: "grpc-gke-proxy", port: 8000
        system "gcloud compute -q forwarding-rules create #{forwarding_rule_name} \
                --global \
                --load-balancing-scheme=INTERNAL_SELF_MANAGED \
                --address=0.0.0.0 \
                --target-grpc-proxy=#{proxy_name} \
                --ports #{port} \
                --network #{Souls.configuration.network}"
      end

      def delete_target_grpc_proxy proxy_name: "grpc-gke-proxy"
        system "gcloud compute -q target-grpc-proxies delete #{proxy_name}"
      end

      def create_target_grpc_proxy proxy_name: "grpc-gke-proxy", url_map_name: "grpc-gke-url-map"
        system "gcloud compute -q target-grpc-proxies create #{proxy_name} \
                --url-map #{url_map_name} \
                --validate-for-proxyless"
      end

      def create_path_matcher url_map_name: "grpc-gke-url-map", service_name: "grpc-gke-helloworld-service", path_matcher_name: "grpc-gke-path-matcher", hostname: "helloworld-gke", port: "8000"
        system "gcloud compute -q url-maps add-path-matcher #{url_map_name} \
                --default-service #{service_name} \
                --path-matcher-name #{path_matcher_name} \
                --new-hosts #{hostname}:#{port}"
      end

      def delete_url_map url_map_name: "grpc-gke-url-map"
        system "gcloud compute -q url-maps delete #{url_map_name}"
      end

      def create_url_map url_map_name: "grpc-gke-url-map", service_name: "grpc-gke-helloworld-service"
        system "gcloud compute -q url-maps create #{url_map_name} \
                --default-service #{service_name}"
      end

      def add_backend_service service_name: "grpc-gke-helloworld-service", zone: "us-central1-a", neg_name: ""
        system "gcloud compute -q backend-services add-backend #{service_name} \
                --global \
                --network-endpoint-group #{neg_name} \
                --network-endpoint-group-zone #{zone} \
                --balancing-mode RATE \
                --max-rate-per-endpoint 5"
      end

      def delete_backend_service service_name: "grpc-gke-helloworld-service"
        system "gcloud compute -q backend-services delete #{service_name} --global"
      end

      def create_backend_service service_name: "grpc-gke-helloworld-service", health_check_name: "grpc-gke-helloworld-hc"
        system "gcloud compute -q backend-services create #{service_name} \
                --global \
                --load-balancing-scheme=INTERNAL_SELF_MANAGED \
                --protocol=GRPC \
                --health-checks #{health_check_name}"
      end

      def delete_firewall_rule firewall_rule_name: "grpc-gke-allow-health-checks"
        system "gcloud compute -q firewall-rules delete #{firewall_rule_name}"
      end

      def create_firewall_rule firewall_rule_name: "grpc-gke-allow-health-checks"
        system "gcloud compute -q firewall-rules create #{firewall_rule_name} \
                --network #{Souls.configuration.network} \
                --action allow \
                --direction INGRESS \
                --source-ranges 35.191.0.0/16,130.211.0.0/22 \
                --target-tags allow-health-checks \
                --rules tcp:50051"
      end

      def delete_health_check health_check_name: "grpc-gke-helloworld-hc"
        system "gcloud compute -q health-checks delete #{health_check_name}"
      end

      def create_health_check health_check_name: "grpc-gke-helloworld-hc"
        system "gcloud compute -q health-checks create grpc #{health_check_name} --use-serving-port"
      end

      def create_network
        return "Error: Please Set Souls.configuration" if Souls.configuration.nil?
        system("gcloud compute networks create #{Souls.configuration.network}")
      end

      def get_network_group_list
        system "gcloud compute network-endpoint-groups list"
      end

      def create_network_group
        app = Souls.configuration.app
        network = Souls.configuration.network
        sub_network = Souls.configuration.network
        system("gcloud compute network-endpoint-groups create #{app} \
                --default-port=0 \
                --network #{network} \
                --subnet #{sub_network} \
                --global")
      end

      def set_network_group_list_env
        app = Souls.configuration.app
        system "NEG_NAME=$(gcloud compute network-endpoint-groups list | grep #{app} | awk '{print $1}')"
        `echo $NEG_NAME`
      end

      def delete_network_group_list neg_name: ""
        system "gcloud compute network-endpoint-groups delete #{neg_name} --zone #{Souls.configuration.zone} -q"
      end

      def delete_cluster cluster_name: "grpc-td-cluster"
        system "gcloud container clusters delete #{cluster_name} --zone #{Souls.configuration.zone} -q"
      end

      def config_set
        system "gcloud config set project #{Souls.configuration.project_id}"
      end

      def create_cluster
        app = Souls.configuration.app
        network = Souls.configuration.network
        sub_network = Souls.configuration.network
        machine_type = Souls.configuration.machine_type
        zone = Souls.configuration.zone
        system("gcloud container clusters create #{app} \
                --network #{network} \
                --subnetwork #{sub_network} \
                --zone #{zone} \
                --scopes=https://www.googleapis.com/auth/cloud-platform \
                --machine-type #{machine_type} \
                --enable-autorepair \
                --enable-ip-alias \
                --num-nodes 2 \
                --enable-autoscaling \
                --min-nodes 1 \
                --max-nodes 4 \
                --tags=allow-health-checks")
      end

      def deploy
        system "souls i config_set"
        system "souls i create_cluster"
        system "souls i create_namespace"
        system "souls i create_ip"
        system "souls i apply_deployment"
      end

      def resize_cluster pool_name: "default-pool", node_num: 1
        app = Souls.configuration.app
        zone = Souls.configuration.zone
        system "gcloud container clusters resize #{app} --node-pool #{pool_name} --num-nodes #{node_num} --zone #{zone}"
      end

      def create_namespace
        app = Souls.configuration.app
        system("kubectl create namespace #{app}")
      end

      def create_ip
        ip_name = Souls.configuration.app.to_s + "-ip"
        system("gcloud compute addresses create #{ip_name} --global")
      end

      def apply_deployment
        app = Souls.configuration.app
        system("kubectl apply -f ./infra/deployment.yml --namespace=#{app}")
      end

      def apply_secret
        app = Souls.configuration.app
        system("kubectl apply -f ./infra/secret.yml --namespace=#{app}")
      end

      def apply_service
        app = Souls.configuration.app
        system("kubectl apply -f ./infra/service.yml --namespace=#{app}")
      end

      def apply_ingress
        app = Souls.configuration.app
        system("kubectl apply -f ./infra/ingress.yml --namespace=#{app}")
      end

      def delete_deployment
        app = Souls.configuration.app
        system("kubectl delete -f ./infra/deployment.yml --namespace=#{app}")
      end

      def delete_secret
        app = Souls.configuration.app
        system("kubectl delete -f ./infra/secret.yml --namespace=#{app}")
      end

      def delete_service
        app = Souls.configuration.app
        system("kubectl delete -f ./infra/service.yml --namespace=#{app}")
      end

      def delete_ingress
        app = Souls.configuration.app
        system("kubectl delete -f ./infra/ingress.yml --namespace=#{app}")
      end

      # zone = :us, :eu or :asia
      def update_container version: "latest", zone: :asia
        zones = {
          us: "gcr.io",
          eu: "eu.gcr.io",
          asia: "asia.gcr.io"
        }
        app = Souls.configuration.app
        project_id = Souls.configuration.project_id
        system("docker build . -t #{app}:#{version}")
        system("docker tag #{app}:#{version} #{zones[zone]}/#{project_id}/#{app}:#{version}")
        system("docker push #{zones[zone]}/#{project_id}/#{app}:#{version}")
      end

      def get_pods
        app = Souls.configuration.app
        system("kubectl get pods --namespace=#{app}")
      end

      def get_svc
        app = Souls.configuration.app
        system("kubectl get svc --namespace=#{app}")
      end

      def get_ingress
        app = Souls.configuration.app
        system("kubectl get ingress --namespace=#{app}")
      end

      def run
        app = Souls.configuration.app
        system("docker rm -f web")
        system("docker build . -t #{app}:latest")
        system("docker run --name web -it --env-file $PWD/.env -p 3000:3000 #{app}:latest")
      end

      def get_clusters
        system("kubectl config get-clusters")
      end

      def get_current_cluster
        system("kubectl config current-context")
      end

      def use_context cluster:
        system("kubectl config use-context #{cluster}")
      end

      def get_credentials
        app = Souls.configuration.app
        zone = Souls.configuration.zone
        system "gcloud container clusters get-credentials #{app} --zone #{zone}"
      end

      def create_ssl
        app = Souls.configuration.app
        domain = Souls.configuration.domain
        system "gcloud compute ssl-certificates create #{app}-ssl --domains=#{domain} --global"
      end

      def update_proxy
        system("gcloud compute target-https-proxies update TARGET_PROXY_NAME \
        --ssl-certificates SSL_CERTIFICATE_LIST \
        --global-ssl-certificates \
        --global")
      end
    end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :project_id, :app, :network, :machine_type, :zone, :domain, :google_application_credentials, :strain, :proto_package_name

    def initialize
      @project_id = nil
      @app = nil
      @network = nil
      @machine_type = nil
      @zone = nil
      @domain = nil
      @google_application_credentials = nil
      @strain = nil
      @proto_package_name = nil
    end
  end
end
