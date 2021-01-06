require "souls/version"
require "souls/init"
require "json"

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
        network = Souls.configuration.network
        system "gcloud compute -q firewall-rules create #{firewall_rule_name} \
                --network #{network} \
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
        network = Souls.configuration.network
        system "gcloud compute networks create #{network}"
      end

      def create_firewall_tcp ip_range:
        network = Souls.configuration.network
        `gcloud compute firewall-rules create #{network} --network #{network} --allow tcp,udp,icmp --source-ranges #{ip_range}`
      end

      def create_firewall_ssh
        network = Souls.configuration.network
        `gcloud compute firewall-rules create #{network}-ssh --network #{network} --allow tcp:22,tcp:3389,icmp`
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

      def export_network_group
        app = Souls.configuration.app
        system "NEG_NAME=$(gcloud compute network-endpoint-groups list | grep #{app} | awk '{print $1}')"
        `echo $NEG_NAME > ./infra/config/neg_name`
      end

      def delete_network_group_list neg_name:
        zone = Souls.configuration.zone
        system "gcloud compute network-endpoint-groups delete #{neg_name} --zone #{zone} -q"
      end

      def delete_cluster
        app = Souls.configuration.app
        zone = Souls.configuration.zone
        system "gcloud container clusters delete #{app} --zone #{zone} -q"
      end

      def config_set_main
        project_id = Souls.configuration.main_project_id
        system "gcloud config set project #{project_id}"
      end

      def config_set
        project_id = Souls.configuration.project_id
        system "gcloud config set project #{project_id}"
      end

      def config_set
        project_id = Souls.configuration.project_id
        system "gcloud config set project #{project_id}"
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
        strain = Souls.configuration.strain
        case strain
        when "api"
          Souls::Init.api_deploy
        when "service"
          Souls::Init.service_deploy
        else
          puts "coming soon..."
        end
      end

      def update
        `souls i apply_deployment`
      end

      def resize_cluster pool_name: "default-pool", node_num: 1
        app = Souls.configuration.app
        zone = Souls.configuration.zone
        system "gcloud container clusters resize #{app} --node-pool #{pool_name} --num-nodes #{node_num} --zone #{zone}"
      end

      def create_namespace
        namespace = Souls.configuration.namespace
        system("kubectl create namespace #{namespace}")
      end

      def create_ip
        ip_name = "#{Souls.configuration.app}-ip"
        system("gcloud compute addresses create #{ip_name} --global")
      end

      def apply_deployment
        namespace = Souls.configuration.namespace
        system("kubectl apply -f ./infra/deployment.yml --namespace=#{namespace}")
      end

      def apply_secret
        namespace = Souls.configuration.namespace
        system("kubectl apply -f ./infra/secret.yml --namespace=#{namespace}")
      end

      def apply_service
        namespace = Souls.configuration.namespace
        system("kubectl apply -f ./infra/service.yml --namespace=#{namespace}")
      end

      def apply_ingress
        namespace = Souls.configuration.namespace
        system("kubectl apply -f ./infra/ingress.yml --namespace=#{namespace}")
      end

      def delete_deployment
        namespace = Souls.configuration.namespace
        system("kubectl delete -f ./infra/deployment.yml --namespace=#{namespace}")
      end

      def delete_secret
        namespace = Souls.configuration.namespace
        system("kubectl delete -f ./infra/secret.yml --namespace=#{namespace}")
      end

      def delete_service
        namespace = Souls.configuration.namespace
        system("kubectl delete -f ./infra/service.yml --namespace=#{namespace}")
      end

      def delete_ingress
        namespace = Souls.configuration.namespace
        system("kubectl delete -f ./infra/ingress.yml --namespace=#{namespace}")
      end

      def create_dns_conf
        app = Souls.configuration.app
        namespace = Souls.configuration.namespace
        domain = Souls.configuration.domain
        `echo "#{domain}. 300 IN A $(kubectl get ingress --namespace #{namespace} | grep #{app} | awk '{print $3}')" >> ./infra/dns_conf`
        "created dns file!"
      end

      def set_dns
        project_id = Souls.configuration.main_project_id
        `gcloud dns record-sets import -z=#{project_id} --zone-file-format ./infra/dns_conf`
      end

      def service_api_enable
        `gcloud services enable iam.googleapis.com`
        `gcloud services enable dns.googleapis.com`
        `gcloud services enable container.googleapis.com`
        `gcloud services enable containerregistry.googleapis.com`
        `gcloud services enable servicenetworking.googleapis.com`
        `gcloud services enable sqladmin.googleapis.com`
        `gcloud services enable sql-component.googleapis.com`
        `gcloud services enable cloudbuild.googleapis.com`
      end

      def update_container zone: :asia
        project_id = Souls.configuration.project_id
        firestore = Google::Cloud::Firestore.new
        strain = Souls.configuration.strain
        app = Souls.configuration.app
        container = case strain
                    when "api"
                      app
                    else
                      Souls.configuration.service_name
                    end
        zones = {
          us: "gcr.io",
          eu: "eu.gcr.io",
          asia: "asia.gcr.io"
        }
        versions = firestore.doc "containers/#{container}/versions/1"
        if versions.get.exists?
          versions = firestore.col("containers").doc(container).col("versions")
          query = versions.order("version_counter", "desc").limit 1
          query.get do |v|
            @next_version = v.data[:version_counter] + 1
          end
        else
          @next_version = 1
        end
        version = firestore.col("containers").doc(container).col("versions").doc @next_version
        version.set version: "v#{@next_version}", version_counter: @next_version, zone: zones[zone], created_at: Time.now.utc

        system("docker build . -t #{app}:v#{@next_version}")
        system("docker tag #{app}:v#{@next_version} #{zones[zone]}/#{project_id}/#{app}:v#{@next_version}")
        system("docker push #{zones[zone]}/#{project_id}/#{app}:v#{@next_version}")
      end

      def create_service_account
        service_account = Souls.configuration.app
        `gcloud iam service-accounts create #{service_account} \
        --description="Souls Service Account" \
        --display-name="#{service_account}"`
      end

      def create_service_account_key
        project_id = Souls.configuration.project_id
        service_account = Souls.configuration.app
        `gcloud iam service-accounts keys create ./config/keyfile.json \
          --iam-account #{service_account}@#{project_id}.iam.gserviceaccount.com`
      end

      def add_service_account_role role: "roles/firebase.admin"
        project_id = Souls.configuration.project_id
        service_account = Souls.configuration.app
        `gcloud projects add-iam-policy-binding #{project_id} \
        --member="serviceAccount:#{service_account}@#{project_id}.iam.gserviceaccount.com" \
        --role="#{role}"`
      end

      def get_pods
        namespace = Souls.configuration.namespace
        system("kubectl get pods --namespace=#{namespace}")
      end

      def get_svc
        namespace = Souls.configuration.namespace
        system("kubectl get svc --namespace=#{namespace}")
      end

      def get_ingress
        namespace = Souls.configuration.namespace
        system("kubectl get ingress --namespace=#{namespace}")
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

      def run_psql
        `docker run --rm -d \
          -p 5433:5432 \
          -v postgres-tmp:/var/lib/postgresql/data \
          -e POSTGRES_USER=postgres \
          -e POSTGRES_PASSWORD=postgres \
          -e POSTGRES_DB=souls_dev \
          postgres:12-alpine`
        system "docker ps"
      end

      def deploy_local
        `docker network create --driver bridge shared`
        `docker run -d --name proxy \
         -p 80:80 -p 443:443 \
         -v "/var/run/docker.sock:/tmp/docker.sock:ro" \
         -v "$pwd/certs:/etc/nginx/certs:ro" \
         -v "/etc/nginx/vhost.d" \
         -v "/usr/share/nginx/html" \
         --network shared \
         --restart always \
         jwilder/nginx-proxy`
        `docker run -d --name letsencrypt \
        -v "/home/certs:/etc/nginx/certs" \
        -v "/var/run/docker.sock:/var/run/docker.sock:ro" \
        --volumes-from proxy \
        --network shared \
        --restart always \
        jrcs/letsencrypt-nginx-proxy-companion`
        `docker run -d --name nginx \
        -p 80:80 \
        -e VIRTUAL_HOST=souls.el-soul.com \
        -e LETSENCRYPT_HOST=souls.el-soul.com \
        -e LETSENCRYPT_EMAIL=info@gmail.com \
        --network shared \
        --link web \
        poppinfumi/nginx-http:latest`
        `docker run -d --name web \
         -p 3000:3000 \
         --network shared \
         asia.gcr.io/kaien-elixir/kaien:v2`
      end
    end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :main_project_id, :project_id, :app, :network, :namespace, :service_name, :machine_type, :zone, :domain, :google_application_credentials, :strain, :proto_package_name

    def initialize
      @main_project_id = nil
      @project_id = nil
      @app = nil
      @network = nil
      @namespace = nil
      @service_name = nil
      @machine_type = nil
      @zone = nil
      @domain = nil
      @google_application_credentials = nil
      @strain = nil
      @proto_package_name = nil
    end
  end
end
