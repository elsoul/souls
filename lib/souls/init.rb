module Souls
  STRAINS = ["service", "api", "graph", "media", "admin"]
  module Init
    class << self
      def create_souls strain: 1, app_name: "souls"
        config_needed = (1..2)
        project = {}
        project[:strain] = STRAINS[strain.to_i - 1]
        begin
          puts "Google Cloud Main PROJECT_ID(This project will controll Cloud DNS):      (default: elsoul2)"
          project[:main_project_id] = STDIN.gets.chomp
          project[:main_project_id] == "" ? project[:main_project_id] = "elsoul2" : true
          puts "Google Cloud PROJECT_ID:      (default: elsoul2)"
          project[:project_id] = STDIN.gets.chomp
          project[:project_id] = "elsoul2" if project[:project_id] == ""
          puts "VPC Network Name:          (default: default)"
          project[:network] = STDIN.gets.chomp
          project[:network] == "" ? project[:network] = "default" : true
          puts "Namespace:          (default: souls)"
          project[:namespace] = STDIN.gets.chomp
          project[:namespace] == "" ? project[:namespace] = "souls" : true
          if project[:strain] == "service"
            puts "Service Name:          (default: blog-service)"
            project[:service_name] = STDIN.gets.chomp
            project[:service_name] == "" ? project[:service_name] = "blog-service" : true
          end
          puts "Instance MachineType:       (default: custom-1-6656)"
          project[:machine_type] = STDIN.gets.chomp
          project[:machine_type] == "" ? project[:machine_type] = "custom-1-6656" : true
          puts "Zone:           (default: us-central1-a)"
          project[:zone] = STDIN.gets.chomp
          project[:zone] == "" ? project[:zone] = "us-central1-a" : true
          puts "Domain:          (e.g API: el-soul.com, Serive: xds:///blog-service:8000)"
          project[:domain] = STDIN.gets.chomp
          project[:domain] == "" ? project[:domain] = "el-soul.com" : true
          puts "Google Application Credentials Path:      (default: #{app_name}/config/credentials.json)"
          project[:google_application_credentials] = STDIN.gets.chomp
          project[:google_application_credentials] == "" ? project[:google_application_credentials] = "./config/credentials.json" : true
          puts project
          puts "Enter to finish set up!"
          confirm = STDIN.gets.chomp
          raise StandardError, "Retry" unless confirm == ""
          download_souls app_name: app_name, repository_name: "souls_#{STRAINS[strain.to_i - 1]}"
          initial_config_init app_name: app_name, project: project if config_needed.include?(strain)
        rescue StandardError => error
          puts error
          retry
        end
      end

      def initial_config_init app_name: "souls", project: {}
        puts "Generating souls conf..."
        `touch "#{app_name}/config/initializers/souls.rb"`
        file_path = "#{app_name}/config/initializers/souls.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            Souls.configure do |config|
              config.main_project_id = "#{project[:main_project_id]}"
              config.project_id = "#{project[:project_id]}"
              config.app = "#{app_name}"
              config.namespace = "#{project[:namespace]}"
              config.service_name = "#{project[:service_name]}"
              config.network = "#{project[:network]}"
              config.machine_type = "#{project[:machine_type]}"
              config.zone = "#{project[:zone]}"
              config.domain = "#{project[:domain]}"
              config.google_application_credentials = "#{project[:google_application_credentials]}"
              config.strain = "#{project[:strain]}"
              config.proto_package_name = "souls"
            end
          EOS
        end
      end

      def config_init app_name: "souls", project: {}
        `touch ./config/initializers/souls.rb`
        file_path = "./config/initializers/souls.rb"
        puts "Generating souls conf..."
        sleep(rand(0.1..0.3))
        puts "Generated!"
        puts "Let's Edit SOULs Conf: `#{file_path}`"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            Souls.configure do |config|
              config.main_project_id = "#{project[:main_project_id]}"
              config.project_id = "#{project[:project_id]}"
              config.app = "#{app_name}"
              config.namespace = "#{project[:namespace]}"
              config.service_name = "#{project[:service_name]}"
              config.network = "#{project[:network]}"
              config.machine_type = "#{project[:machine_type]}"
              config.zone = "#{project[:zone]}"
              config.domain = "#{project[:domain]}"
              config.google_application_credentials = "#{project[:google_application_credentials]}"
              config.strain = "#{project[:strain]}"
              config.proto_package_name = "souls"
            end
          EOS
        end
      end

      def get_version repository_name: "souls_service"
        data = JSON.parse `curl \
        -H "Accept: application/vnd.github.v3+json" \
        -s https://api.github.com/repos/elsoul/#{repository_name}/releases`
        data[0]["tag_name"]
      end

      def download_souls app_name: "souls", repository_name: "souls_service"
        version = get_version repository_name: repository_name
        system "curl -OL https://github.com/elsoul/#{repository_name}/archive/#{version}.tar.gz"
        system "tar -zxvf ./#{version}.tar.gz"
        system "mkdir #{app_name}"
        folder = version.delete "v"
        system "cp -r #{repository_name}-#{folder}/ #{app_name}/"
        system "rm -rf #{version}.tar.gz && rm -rf #{repository_name}-#{folder}"
        txt = <<~TEXT
           _____ ____  __  ____        
          / ___// __ \\/ / / / /   _____
          \\__ \\/ / / / / / / /   / ___/
         ___/ / /_/ / /_/ / /___(__  ) 
        /____/\\____/\\____/_____/____/  
        TEXT
        puts txt
        puts "=============================="
        puts "Welcome to SOULs!"
        puts "SOULs Version: #{Souls::VERSION}"
        puts "=============================="
        puts "$ cd #{app_name}"
        puts "------------------------------"
      end

      def proto proto_package_name: "souls", service: "blog"
        system "grpc_tools_ruby_protoc -I ./protos --ruby_out=./app/services --grpc_out=./app/services ./protos/#{service}.proto"
        service_pb_path = "./app/services/#{service}_services_pb.rb"
        new_file = "./app/services/#{proto_package_name}.rb"
        File.open(new_file, "w") do |new_line|
          File.open(service_pb_path, "r") do |f|
            f.each_line.with_index do |line, i|
              case i
              when 0
                new_line.write "# Generated by the SOULs protocol buffer compiler.  DO NOT EDIT!\n"
              when 3
                next
              else
                puts "#{i}: #{line}"
                new_line.write line.to_s
              end
            end
          end
        end
        FileUtils.rm service_pb_path
        puts "SOULs Proto Created!"
      end

      def service_deploy
        service_name = Souls.configuration.service_name
        health_check_name = "#{service_name}-hc"
        firewall_rule_name = "#{service_name}-allow-health-checks"
        zone = Souls.configuration.zone
        url_map_name = "#{service_name}-url-map"
        path_matcher_name = "#{service_name}-path-mathcher"
        port = "5000"
        proxy_name = "#{service_name}-proxy"
        forwarding_rule_name = "#{service_name}-forwarding-rule"

        Souls.create_service_account
        Souls.create_service_account_key
        Souls.add_service_account_role
        Souls.add_service_account_role role: "roles/containerregistry.ServiceAgent"
        Souls.create_health_check health_check_name: health_check_name
        Souls.create_firewall_rule firewall_rule_name: firewall_rule_name
        Souls.create_backend_service service_name: service_name, health_check_name: health_check_name
        Souls.export_network_group
        file_path = "./config/neg_name"
        File.open(file_path) do |f|
          Souls.add_backend_service service_name: service_name, neg_name: f.gets.to_s, zone: zone
        end
        Souls.create_url_map url_map_name: url_map_name, service_name: service_name
        Souls.create_path_matcher url_map_name: url_map_name, service_name: service_name, path_matcher_name: path_matcher_name, hostname: app, port: port
        Souls.create_target_grpc_proxy proxy_name: proxy_name, url_map_name: url_map_name
        Souls.create_forwarding_rule forwarding_rule_name: forwarding_rule_name, proxy_name: proxy_name, port: port
      end

      def api_deploy
        Souls.service_api_enable
        Souls.create_service_account
        Souls.create_service_account_key
        Souls.add_service_account_role
        Souls.add_service_account_role role: "roles/containerregistry.ServiceAgent"
        Souls.config_set
        Souls.create_network
        Souls.create_cluster
        Souls.get_credentials
        Souls.create_namespace
        Souls.create_ip
        Souls.create_ssl
        Souls.apply_deployment
        Souls.apply_service
        Souls.apply_ingress
        puts "Wainting for Ingress to get IP..."
        sleep 1
        puts "This migth take a few mins..."
        sleep 90
        Souls.create_dns_conf
        Souls.config_set_main
        Souls.set_dns
        Souls.config_set
      end

      def local_deploy
        `souls i run_psql`
        `docker pull`
      end

      def service_update
        `souls i apply_deployment`
      end

      def api_update
        `souls i apply_deployment`
      end

      def service_delete
        service_name = Souls.configuration.service_name
        firewall_rule_name = "#{service_name}-allow-health-checks"
        url_map_name = "#{service_name}-url-map"
        proxy_name = "#{service_name}-proxy"
        forwarding_rule_name = "#{service_name}-forwarding-rule"

        Souls.delete_forwarding_rule forwarding_rule_name: forwarding_rule_name
        Souls.delete_target_grpc_proxy proxy_name: proxy_name
        Souls.delete_url_map url_map_name: url_map_name
        Souls.delete_backend_service service_name: service_name
        Souls.delete_health_check health_check_name: health_check_name
        Souls.delete_firewall_rule firewall_rule_name: firewall_rule_name
      end

      def api_delete
        `souls i delete_deployment`
        `souls i delete_secret`
        `souls i delete_service`
        `souls i delete_ingress`
      end

      def model class_name: "souls"
        file_path = "./app/models/#{class_name}.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            class #{class_name.capitalize} < ActiveRecord::Base
            end
          EOS
        end
        puts "model #{class_name}.rb created!: `#{file_path}`"
      end

      def type_check type
        {
          bigint: "Integer",
          string: "String",
          text: "String",
          datetime: "GraphQL::Types::ISO8601DateTime",
          boolean: "Boolean",
          integer: "Integer"
        }[type.to_sym]
      end

      def table_check line: "", class_name: ""
        if line.include?("create_table")
          return true if line.split(" ")[1].gsub("\"", "").gsub(",", "") == "#{class_name}s"
        end
        false
      end

      # def mutation class_name: "souls"
      #   file_path = "./app/graphql/mutations/create_#{class_name}.rb"
      #   path = "./db/schema.rb"
      #   File.open(file_path, "w") do |new_line|
      #     new_line.write <<~EOS
      #       module Mutations
      #         class Create#{class_name.capitalize} < BaseMutation
      #           field :#{class_name}, Types::#{class_name.capitalize}Type, null: false
      #           field :error, String, null: true

      #           ## Change argument as you needed
      #           # argument :id, Integer, required: true
      #           # argument :title, String, required: true
      #           # argument :tag, [String], required: false
      #           # argument :is_public, Boolean, required: true
      #           # argument :public_date, GraphQL::Types::ISO8601DateTime, required: true
      #     EOS
      #     File.open(path, "r") do |f|
      #       f.each_line.with_index do |line, i|
      #         puts line
      #         if table_check(line: line, class_name: class_name)
      #           type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
      #           field = type_check type
      #           new_line.write "argument :#{name}, #{field} , required: false"
      #           break if line.include?("end")
      #         end
      #       end
      #     end
      #     new_line.write <<~EOS
      #       def resolve **args
      #             #{class_name} = #{class_name.capitalize}.new args
      #             if #{class_name}.save
      #               { #{class_name}: #{class_name} }
      #             else
      #               { error: #{class_name}.errors.full_messages }
      #             end
      #           rescue StandardError => error
      #             GraphQL::ExecutionError.new error
      #           end
      #         end
      #       end
      #     EOS
      #   end
      #   puts "mutation create_#{class_name}.rb created!: `#{file_path}`"
      # end

      def query class_name: "souls"
        file_path = "./app/graphql/queries/#{class_name}s.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            module Queries
              class #{class_name.capitalize}s < Queries::BaseQuery
                type [Types::#{class_name.capitalize}Type], null: false

                def resolve
                  ::#{class_name.capitalize}.all
                rescue StandardError => error
                  GraphQL::ExecutionError.new error
                end
              end
            end
          EOS
        end
        puts "query #{class_name}s.rb created!: `#{file_path}`"
        file_path = "./app/graphql/queries/#{class_name}.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            module Queries
              class #{class_name.capitalize} < Queries::BaseQuery
                type Types::#{class_name.capitalize}Type, null: false
                argument :id, Integer, required: true

                def resolve id:
                  ::#{class_name.capitalize}.find(id)
                rescue StandardError => error
                  GraphQL::ExecutionError.new error
                end
              end
            end
          EOS
          puts "query #{class_name}.rb created!: `#{file_path}`"
        end
      end

      def type class_name: "souls"
        file_path = "./app/graphql/types/#{class_name}_type.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            module Types
              class #{class_name.capitalize}Type < GraphQL::Schema::Object
                implements GraphQL::Types::Relay::Node

                ## Change field as you needed
                # global_id_field :id
                # field :user, Types::UserType, null: false
                # field :title, String, null: false
                # field :tag, [String], null: true
                # field :public_date, GraphQL::Types::ISO8601DateTime, null: false
                # field :is_public, Boolean, null: false
                # field :article_category, Types::ArticleCategoryType, null: false
                # field :created_at, GraphQL::Types::ISO8601DateTime, null: true
                # field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
              end
            end
          EOS
        end
        puts "type #{class_name}.rb created!: `#{file_path}`"
      end

      def rspec_model class_name: "souls"
        file_path = "./spec/models/#{class_name}_spec.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            RSpec.describe #{class_name.capitalize}, type: :model do
              it "作成する" do
                expect(FactoryBot.build(:#{class_name})).to be_valid
              end

              it "同じtitleがあると作成できない" do
                FactoryBot.build(:#{class_name}, title: "hey")
                expect(FactoryBot.build(:#{class_name}, title: "hey")).to be_valid
              end
            end
          EOS
        end
        puts "rspec_model #{class_name}_spec.rb created!: `#{file_path}`"
      end

      def rspec_mutation class_name: "souls"
      end

      def rspec_query class_name: "souls"
      end

      def rspec_type class_name: "souls"
      end

      def migration class_name: "souls"
        model class_name: class_name
        mutation class_name: class_name
        query class_name: class_name
        type class_name: class_name
        rspec_model class_name: class_name
      end

    end
  end
end