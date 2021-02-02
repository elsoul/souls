module Souls
  STRAINS = ["graph", "api", "service", "media", "admin"]
  module Init
    class << self
      def create_souls strain: 1, app_name: "souls"
        config_needed = (1..3)
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
           _____ ____  __  ____#{'        '}
          / ___// __ \\/ / / / /   _____
          \\__ \\/ / / / / / / /   / ___/
         ___/ / /_/ / /_/ / /___(__  )#{' '}
        /____/\\____/\\____/_____/____/#{'  '}
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
        file_path = "./app/models/#{class_name.singularize}.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            class #{class_name.camelize} < ActiveRecord::Base
            end
          EOS
        end
        [file_path]
      end

      def test_dir
        FileUtils.mkdir_p "./app/graphql/mutations"
        FileUtils.mkdir_p "./app/graphql/queries"
        FileUtils.mkdir_p "./app/graphql/types"
        FileUtils.mkdir_p "./spec/factories"
        FileUtils.mkdir_p "./spec/queries"
        FileUtils.mkdir_p "./spec/mutations"
        FileUtils.mkdir_p "./spec/models"
        FileUtils.mkdir_p "./db/"
        FileUtils.touch "./db/schema.rb"
        puts "test dir created!"
      end

      def type_check type
        {
          bigint: "Integer",
          string: "String",
          float: "Float",
          text: "String",
          datetime: "GraphQL::Types::ISO8601DateTime",
          date: "GraphQL::Types::ISO8601DateTime",
          boolean: "Boolean",
          integer: "Integer"
        }[type.to_sym]
      end

      def get_test_type type
        {
          bigint: 1,
          float: 4.2,
          string: '"MyString"',
          text: '"MyString"',
          datetime: "DateTime.now",
          date: "DateTime.now",
          boolean: false,
          integer: 1
        }[type.to_sym]
      end

      def table_check line: "", class_name: ""
        if line.include?("create_table") && (line.split(" ")[1].gsub("\"", "").gsub(",", "") == class_name.pluralize.to_s)
          return true
        end
        false
      end

      def create_mutation_head class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/create_#{class_name}.rb"
        File.open(file_path, "w") do |new_line|
          new_line.write <<~EOS
            module Mutations
              module #{class_name.camelize}
                class Create#{class_name.camelize} < BaseMutation
                  field :#{class_name}, Types::#{class_name.camelize}Type, null: false
                  field :error, String, null: true

          EOS
        end
      end

      def create_mutation_params class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/create_#{class_name}.rb"
        path = "./db/schema.rb"
        @on = false
        @user_exist = false
        @relation_params = []
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  if @user_exist
                    new_line.write <<-EOS

      def resolve **args
        args[:user_id] = context[:user].id
                    EOS
                  else
                    new_line.write <<-EOS

      def resolve **args
                    EOS
                  end
                  break
                end
                field = "[String]" if line.include?("array: true")
                type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                field ||= type_check type
                case name
                when "user_id"
                  @user_exist = true
                when /$*_id\z/
                  @relation_params << name
                  new_line.write "      argument :#{name}, String, required: false\n"
                when "created_at", "updated_at"
                  next
                else
                  new_line.write "      argument :#{name}, #{field}, required: false\n"
                end
              end
              @on = true if table_check(line: line, class_name: class_name)
            end
          end
        end
        @relation_params
      end

      def create_mutation_after_params class_name: "article", relation_params: []
        return false if relation_params.empty?
        file_path = "./app/graphql/mutations/#{class_name}/create_#{class_name}.rb"
        relation_params.each do |params_name|
          File.open(file_path, "a") do |new_line|
            new_line.write "        _, args[:#{params_name}] = SoulsApiSchema.from_global_id(args[:#{params_name}])\n"
          end
        end
        true
      end

      def create_mutation_end class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/create_#{class_name}.rb"
        File.open(file_path, "a") do |new_line|
          new_line.write <<~EOS
                    #{class_name} = ::#{class_name.camelize}.new args
                    if #{class_name}.save
                      { #{class_name}: #{class_name} }
                    else
                      { error: #{class_name}.errors.full_messages }
                    end
                  rescue StandardError => error
                    GraphQL::ExecutionError.new error
                  end
                end
              end
            end
          EOS
        end
        file_path
      end

      def update_mutation_head class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/update_#{class_name}.rb"
        File.open(file_path, "w") do |new_line|
          new_line.write <<~EOS
            module Mutations
              module #{class_name.camelize}
                class Update#{class_name.camelize} < BaseMutation
                  field :#{class_name}, Types::#{class_name.camelize}Type, null: false

                  argument :id, String, required: true
          EOS
        end
      end

      def update_mutation_params class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/update_#{class_name}.rb"
        path = "./db/schema.rb"
        @on = false
        @user_exist = false
        @relation_params = []
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  if @user_exist
                    new_line.write <<-EOS

      def resolve **args
        args[:user_id] = context[:user].id
        _, args[:id] = SoulsApiSchema.from_global_id(args[:id])
                    EOS
                  else
                    new_line.write <<-EOS

      def resolve **args
        _, args[:id] = SoulsApiSchema.from_global_id(args[:id])
                    EOS
                  end
                  break
                end
                field = "[String]" if line.include?("array: true")
                type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                field ||= type_check type
                case name
                when "user_id"
                  @user_exist = true
                when /$*_id\z/
                  @relation_params << name
                  new_line.write "      argument :#{name}, String, required: false\n"
                when "created_at", "updated_at"
                  next
                else
                  new_line.write "      argument :#{name}, #{field}, required: false\n"
                end
              end
              @on = true if table_check(line: line, class_name: class_name)
            end
          end
        end
        @relation_params
      end

      def update_mutation_after_params class_name: "article", relation_params: []
        return false if relation_params.empty?
        file_path = "./app/graphql/mutations/#{class_name}/update_#{class_name}.rb"
        relation_params.each do |params_name|
          File.open(file_path, "a") do |new_line|
            new_line.write "        _, args[:#{params_name}] = SoulsApiSchema.from_global_id(args[:#{params_name}])\n"
          end
        end
        true
      end

      def update_mutation_end class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/update_#{class_name}.rb"
        File.open(file_path, "a") do |new_line|
          new_line.write <<~EOS
                    #{class_name} = ::#{class_name.camelize}.find args[:id]
                    #{class_name}.update args
                    { #{class_name}: ::#{class_name.camelize}.find(args[:id]) }
                  rescue StandardError => error
                    GraphQL::ExecutionError.new error
                  end
                end
              end
            end
          EOS
        end
        file_path
      end

      def update_mutation class_name: "souls"
        update_mutation_head class_name: class_name
        relation_params = update_mutation_params class_name: class_name
        update_mutation_after_params class_name: class_name, relation_params: relation_params
        update_mutation_end class_name: class_name
      end

      def delete_mutation class_name: "souls"
        file_path = "./app/graphql/mutations/#{class_name}/delete_#{class_name}.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            module Mutations
              module #{class_name.camelize}
                class Delete#{class_name.camelize} < BaseMutation
                  field :#{class_name}, Types::#{class_name.camelize}Type, null: false
                  argument :id, String, required: true

                  def resolve **args
                    _, data_id = SoulsApiSchema.from_global_id args[:id]
                    #{class_name} = ::#{class_name.camelize}.find data_id
                    #{class_name}.destroy
                    { #{class_name}: #{class_name} }
                  rescue StandardError => error
                    GraphQL::ExecutionError.new error
                  end
                end
              end
            end
          EOS
        end
        file_path
      end

      def create_confirm dir_path: ""
        puts "Directory already exists, Overwrite?? (Y/N)\n#{dir_path}"
        input = STDIN.gets.chomp
        return true if input == "Y"
        raise StandardError.new "Directory Already Exist!\n#{dir_path}"
      end

      def mutation class_name: "souls"
        singularized_class_name = class_name.singularize
        if Dir.exist? "./app/graphql/mutations/#{singularized_class_name}"
          create_confirm dir_path: "./app/graphql/mutations/#{singularized_class_name}"
        else
          Dir.mkdir "./app/graphql/mutations/#{singularized_class_name}"
        end
        create_mutation_head class_name: singularized_class_name
        relation_params = create_mutation_params class_name: singularized_class_name
        create_mutation_after_params class_name: singularized_class_name, relation_params: relation_params
        [
          create_mutation_end(class_name: singularized_class_name),
          update_mutation(class_name: singularized_class_name),
          delete_mutation(class_name: singularized_class_name)
        ]
      end

      def create_queries class_name: "souls"
        file_path = "./app/graphql/queries/#{class_name.pluralize}.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            module Queries
              class #{class_name.camelize.pluralize} < Queries::BaseQuery
                type [Types::#{class_name.camelize}Type], null: false

                def resolve
                  ::#{class_name.camelize}.all
                rescue StandardError => error
                  GraphQL::ExecutionError.new error
                end
              end
            end
          EOS
        end
        file_path
      end

      def create_query class_name: "souls"
        file_path = "./app/graphql/queries/#{class_name}.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            module Queries
              class #{class_name.camelize} < Queries::BaseQuery
                type Types::#{class_name.camelize}Type, null: false
                argument :id, String, required: true

                def resolve **args
                  _, data_id = SoulsApiSchema.from_global_id args[:id]
                  ::#{class_name.camelize}.find(data_id)
                rescue StandardError => error
                  GraphQL::ExecutionError.new error
                end
              end
            end
          EOS
          file_path
        end
      end

      def query class_name: "souls"
        singularized_class_name = class_name.singularize
        [create_query(class_name: singularized_class_name), create_queries(class_name: singularized_class_name)]
      end

      def create_type_head class_name: "souls"
        file_path = "./app/graphql/types/#{class_name}_type.rb"
          File.open(file_path, "w") do |f|
            f.write <<~EOS
              module Types
                class #{class_name.camelize}Type < GraphQL::Schema::Object
                  implements GraphQL::Types::Relay::Node

            EOS
          end
      end

      def create_type_params class_name: "souls"
        file_path = "./app/graphql/types/#{class_name}_type.rb"
        path = "./db/schema.rb"
        @on = false
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                new_line.write "\n" && break if line.include?("end") || line.include?("t.index")
                field = "[String]" if line.include?("array: true")
                type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                field ||= type_check type
                case name
                when /$*_id\z/
                  new_line.write "    field :#{name.gsub("_id", "")}, Types::#{name.gsub("_id", "").singularize.camelize}Type, null: false\n"
                else
                  new_line.write "    field :#{name}, #{field}, null: true\n"
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
                new_line.write "    global_id_field :id\n"
              end
            end
          end
        end
      end

      def create_type_end class_name: "souls"
        file_path = "./app/graphql/types/#{class_name}_type.rb"
        File.open(file_path, "a") do |f|
          f.write <<~EOS
              end
            end
          EOS
        end
        [file_path]
      end

      def type class_name: "souls"
        singularized_class_name = class_name.singularize
        create_type_head class_name: singularized_class_name
        create_type_params class_name: singularized_class_name
        create_type_end class_name: singularized_class_name
      end

      def rspec_factory_head class_name: "souls"
        file_path = "./spec/factories/#{class_name.pluralize}.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            FactoryBot.define do
              factory :#{class_name} do
          EOS
        end
      end

      def rspec_factory_params class_name: "souls"
        file_path = "./spec/factories/#{class_name.pluralize}.rb"
        path = "./db/schema.rb"
        @on = false
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                new_line.write "\n" && break if line.include?("end") || line.include?("t.index")
                field = '["tag1", "tag2", "tag3"]' if line.include?("array: true")
                type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                field ||= get_test_type type
                if type == "bigint" && name.include?("_id")
                  id_name = name.gsub("_id", "")
                  new_line.write "    association :#{id_name}, factory: :#{id_name}\n"
                else
                  new_line.write "    #{name} { #{field} }\n"
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
              end
            end
          end
        end
      end

      def rspec_factory_end class_name: "souls"
        file_path = "./spec/factories/#{class_name.pluralize}.rb"
        File.open(file_path, "a") do |f|
          f.write <<~EOS
              end
            end
          EOS
        end
        [file_path]
      end

      def rspec_factory class_name: "souls"
        singularized_class_name = class_name.singularize
        rspec_factory_head class_name: singularized_class_name
        rspec_factory_params class_name: singularized_class_name
        rspec_factory_end class_name: singularized_class_name
      end

      def rspec_model class_name: "souls"
        file_path = "./spec/models/#{class_name}_spec.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            RSpec.describe "#{class_name.camelize} Model テスト", type: :model do
              describe "#{class_name.camelize} データを書き込む" do
                it "valid #{class_name.camelize} Model" do
                  expect(FactoryBot.build(:#{class_name.singularize})).to be_valid
                end
              end
            end
          EOS
        end
        [file_path]
      end

      def rspec_mutation_head class_name: "souls"
        file_path = "./spec/mutations/#{class_name.singularize}_spec.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            RSpec.describe \"#{class_name.camelize} Mutation テスト\" do
              describe "#{class_name.camelize} データを登録する" do
          EOS
        end
      end

      def rspec_mutation_after_head class_name: "souls"
        file_path = "./spec/mutations/#{class_name.singularize}_spec.rb"
        path = "./db/schema.rb"
        @on = false
        @user_exist = false
        @relation_params = []
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  if @relation_params.empty?
                    new_line.write <<-EOS
    let(:#{class_name}) { FactoryBot.attributes_for(:#{class_name}) }

    let(:mutation) do
      %(mutation {
        create#{class_name.camelize}(input: {
                    EOS
                  else
                    new_line.write <<-EOS
      
    get_global_key = proc { |class_name, id| Base64.encode64(\"\#{class_name}:\#{id}\") }
    let(:#{class_name}) { FactoryBot.attributes_for(:#{class_name}, #{@relation_params.join(", ")}) }

    let(:mutation) do
      %(mutation {
        create#{class_name.camelize}(input: {
                    EOS
                  end
                  break
                end
                _, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                case name
                when "user_id"
                  relation_col = name.gsub("_id", "")
                  new_line.write "    let(:#{relation_col}) { FactoryBot.create(:#{relation_col}) }\n"
                when /$*_id\z/
                  relation_col = name.gsub("_id", "")
                  @relation_params << "#{name}: get_global_key.call(\"#{name.singularize.camelize.gsub("Id", "")}\", #{relation_col}.id)"
                  new_line.write "    let(:#{relation_col}) { FactoryBot.create(:#{relation_col}) }\n"
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
              end
            end
          end
        end
      end

      def rspec_mutation_params class_name: "souls"
        file_path = "./spec/mutations/#{class_name.singularize}_spec.rb"
        path = "./db/schema.rb"
        @on = false
        @user_exist = false
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  new_line.write "        }) {\n            #{class_name.singularize.camelize(:lower)} {\n              id\n"
                  break
                end
                type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                array_true = line.include?("array: true")
                case name
                when "created_at", "updated_at"
                  next
                when "user_id"
                  @user_exist = true
                when /$*_id\z/
                  new_line.write "          #{name.singularize.camelize(:lower)}: \"\#{#{class_name.singularize}[:#{name.singularize.underscore}]}\"\n"
                else
                  case type
                  when "string", "text", "date", "datetime"
                    if array_true
                      new_line.write "          #{name.pluralize.camelize(:lower)}: \#{#{class_name.singularize}[:#{name.pluralize.underscore}]}\n"
                    else
                      new_line.write "          #{name.singularize.camelize(:lower)}: \"\#{#{class_name.singularize}[:#{name.singularize.underscore}]}\"\n"
                    end
                  when "bigint", "integer", "float", "boolean"
                    new_line.write "          #{name.singularize.camelize(:lower)}: \#{#{class_name.singularize}[:#{name.singularize.underscore}]}\n"
                  end
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
              end
            end
          end
        end
      end

      def rspec_mutation_params_response class_name: "souls"
        file_path = "./spec/mutations/#{class_name.singularize}_spec.rb"
        path = "./db/schema.rb"
        @on = false
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  if @user_exist
                    new_line.write <<-EOS
            }
          }
        }
      )
    end

    subject(:result) do
      context = {
        user: user
      }
      SoulsApiSchema.execute(mutation, context: context).as_json
    end

    it "return #{class_name.camelize} Data" do
      a1 = result.dig("data", "create#{class_name.singularize.camelize}", "#{class_name.singularize.camelize(:lower)}")
      expect(a1).to include(
        "id" => be_a(String),
                    EOS
                  else
                    new_line.write <<-EOS
            }
          }
        }
      )
    end

    subject(:result) do
      SoulsApiSchema.execute(mutation).as_json
    end

    it "return #{class_name.camelize} Data" do
      a1 = result.dig("data", "create#{class_name.singularize.camelize}", "#{class_name.singularize.camelize(:lower)}")
      expect(a1).to include(
        "id" => be_a(String),
                    EOS
                  end
                  break
                end
                _, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                array_true = line.include?("array: true")
                case name
                when "user_id", "created_at", "updated_at", /$*_id\z/
                  next
                else
                  if array_true
                    new_line.write "              #{name.pluralize.camelize(:lower)}\n"
                  else
                    new_line.write "              #{name.singularize.camelize(:lower)}\n"
                  end
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
              end
            end
          end
        end
      end

      def rspec_mutation_end class_name: "souls"
        file_path = "./spec/mutations/#{class_name.singularize}_spec.rb"
        path = "./db/schema.rb"
        @on = false
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on 
                if line.include?("end") || line.include?("t.index")
                  new_line.write <<~EOS
                                )
                            end
                          end
                        end
                  EOS
                  break
                end
                type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                field ||= type_check type
                array_true = line.include?("array: true")
                case name
                when "user_id", "created_at", "updated_at", /$*_id\z/
                  next
                else
                  case type
                  when "text", "date", "datetime"
                      if array_true
                        new_line.write "        \"#{name.pluralize.camelize(:lower)}\" => be_all(String),\n"
                      else
                        new_line.write "        \"#{name.singularize.camelize(:lower)}\" => be_a(String),\n"
                      end
                  when "boolean"
                    new_line.write "        \"#{name.singularize.camelize(:lower)}\" => be_in([true, false]),\n"
                  when "string", "bigint", "integer", "float"
                    new_line.write "        \"#{name.singularize.camelize(:lower)}\" => be_a(#{field}),\n"
                  end
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
              end
            end
          end
        end
        [file_path]
      end

      def rspec_mutation class_name: "souls"
        singularized_class_name = class_name.singularize
        rspec_mutation_head class_name: singularized_class_name
        rspec_mutation_after_head class_name: singularized_class_name
        rspec_mutation_params class_name: singularized_class_name
        rspec_mutation_params_response class_name: singularized_class_name
        rspec_mutation_end class_name: singularized_class_name
      end

      def rspec_query_head class_name: "souls"
        file_path = "./spec/queries/#{class_name.singularize}_spec.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            RSpec.describe \"#{class_name.camelize} Query テスト\" do
              describe "#{class_name.camelize} データを取得する" do
          EOS
        end
      end

      def rspec_query_after_head class_name: "souls"
        file_path = "./spec/queries/#{class_name.singularize}_spec.rb"
        path = "./db/schema.rb"
        @on = false
        @user_exist = false
        @relation_params = []
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                if line.include?("end") || line.include?("t.index")
                  if @relation_params.empty?
                  new_line.write <<-EOS
    let(:#{class_name}) { FactoryBot.create(:#{class_name}) }

    let(:query) do
      data_id = Base64.encode64("#{class_name.camelize}:\#{#{class_name.singularize.underscore}.id}")
      %(query {
        #{class_name.singularize.camelize(:lower)}(id: \\"\#{data_id}\\") {
          id
                  EOS
                  break
                  else
                  new_line.write <<-EOS
    let(:#{class_name}) { FactoryBot.create(:#{class_name}, #{@relation_params.join(", ")}) }

    let(:query) do
      data_id = Base64.encode64("#{class_name.camelize}:\#{#{class_name.singularize.underscore}.id}")
      %(query {
        #{class_name.singularize.camelize(:lower)}(id: \\"\#{data_id}\\") {
          id
                  EOS
                  break
                  end
                end
                _, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                case name
                when /$*_id\z/
                  relation_col = name.gsub("_id", "")
                  @relation_params << "#{name}: #{relation_col}.id"
                  new_line.write "    let(:#{relation_col}) { FactoryBot.create(:#{relation_col}) }\n"
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
              end
            end
          end
        end
      end

      def rspec_query_params class_name: "souls"
        file_path = "./spec/queries/#{class_name.singularize}_spec.rb"
        path = "./db/schema.rb"
        @on = false
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on 
                if line.include?("end") || line.include?("t.index")
                  new_line.write <<-EOS
        }
      }
    )
  end

  subject(:result) do
    SoulsApiSchema.execute(query).as_json
  end

  it "return #{class_name.camelize} Data" do
    a1 = result.dig("data", "#{class_name.singularize.camelize(:lower)}")
    expect(a1).to include(
      "id" => be_a(String),
                  EOS
                  break
                end
                _, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                case name
                when "user_id", "created_at", "updated_at", /$*_id\z/
                  next
                else
                  new_line.write "          #{name.singularize.camelize(:lower)}\n"
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
              end
            end
          end
        end
      end

      def rspec_query_end class_name: "souls"
        file_path = "./spec/queries/#{class_name.singularize}_spec.rb"
        path = "./db/schema.rb"
        @on = false
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on 
                if line.include?("end") || line.include?("t.index")
                  new_line.write <<-EOS
        )
    end
  end
end
                  EOS
                  break
                end
                type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                field ||= type_check type
                array_true = line.include?("array: true")
                case name
                when "user_id", "created_at", "updated_at", /$*_id\z/
                  next
                else
                  case type
                  when "text", "date", "datetime"
                      if array_true
                        new_line.write "        \"#{name.singularize.camelize(:lower)}\" => be_all(String),\n"
                      else
                        new_line.write "        \"#{name.singularize.camelize(:lower)}\" => be_a(String),\n"
                      end
                  when "boolean"
                    new_line.write "        \"#{name.singularize.camelize(:lower)}\" => be_in([true, false]),\n"
                  when "string", "bigint", "integer", "float"
                    new_line.write "        \"#{name.singularize.camelize(:lower)}\" => be_a(#{field}),\n"
                  end
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
              end
            end
          end
        end
        [file_path]
      end

      def rspec_query class_name: "souls"
        singularized_class_name = class_name.singularize
        rspec_query_head class_name: singularized_class_name
        rspec_query_after_head class_name: singularized_class_name
        rspec_query_params class_name: singularized_class_name
        rspec_query_end class_name: singularized_class_name
      end

      def get_end_point
        file_path = "./app/graphql/types/mutation_type.rb"
        File.open(file_path, "r") do |f|
          f.each_line.with_index do |line, i|
            return i if line.include?("end")
          end
        end
      end

      def get_tables
        path = "./db/schema.rb"
        tables = []
        File.open(path, "r") do |f|
          f.each_line.with_index do |line, i|
              tables << line.split("\"")[1] if line.include?("create_table")
          end
        end
        tables
      end

      def add_mutation_type class_name: "souls"
        # let's do this later
      end

      def add_query_type class_name: "souls"
        # let's do this later
      end

      def migrate class_name: "souls"
        singularized_class_name = class_name.singularize
        model_paths = model class_name: singularized_class_name
        type_paths = type class_name: singularized_class_name
        rspec_factory_paths = rspec_factory class_name: singularized_class_name
        rspec_model_paths = rspec_model class_name: singularized_class_name
        rspec_mutation_paths = rspec_mutation class_name: singularized_class_name
        rspec_query_paths = rspec_query class_name: singularized_class_name
        query_path = query class_name: singularized_class_name
        mutation_path = mutation class_name: singularized_class_name
        [
          model: model_paths,
          type: type_paths,
          rspec_factory: rspec_factory_paths,
          rspec_model: rspec_model_paths,
          rspec_mutation: rspec_mutation_paths,
          rspec_query: rspec_query_paths,
          query: query_path,
          mutation: mutation_path,
          add_query_type: [
            "    field :#{singularized_class_name}, resolver: Queries::#{singularized_class_name.camelize}",
            "    field :#{singularized_class_name.pluralize}, Types::#{singularized_class_name.camelize}Type.connection_type, null: true"
          ],
          add_mutation_type: [
            "    field :create_#{singularized_class_name}, mutation: Mutations::#{singularized_class_name.camelize}::Create#{singularized_class_name.camelize}",
            "    field :update_#{singularized_class_name}, mutation: Mutations::#{singularized_class_name.camelize}::Update#{singularized_class_name.camelize}",
            "    field :delete_#{singularized_class_name}, mutation: Mutations::#{singularized_class_name.camelize}::Delete#{singularized_class_name.camelize}"
          ]
        ]
      end

      def single_migrate class_name: "user"
        puts "◆◆◆ Let's Auto Generate CRUD API ◆◆◆\n"
        result = migrate class_name: class_name
        puts result[0][:model]
        puts result[0][:type]
        puts result[0][:rspec_factory]
        puts result[0][:rspec_model]
        puts result[0][:rspec_mutation]
        puts result[0][:rspec_query]
        puts result[0][:query]
        puts result[0][:mutation]

        puts "\nAll files created from ./db/schema.rb"
        puts "\n\n"
        puts "##########################################################\n"
        puts "#                                                        #\n"
        puts "# Add These Lines at ./app/graphql/types/query_type.rb   #\n"
        puts "#                                                        #\n"
        puts "##########################################################\n\n\n"
        result[0][:add_query_type].each do |path|
          puts path
        end
        puts "\n    ## Connection Type\n\n"
        puts "    def #{class_name.pluralize}"
        puts "      #{class_name.singularize.camelize}.all.order(id: :desc)"
        puts "    end\n\n\n"

        puts "#############################################################\n"
        puts "#                                                           #\n"
        puts "# Add These Lines at ./app/graphql/types/mutation_type.rb   #\n"
        puts "#                                                           #\n"
        puts "#############################################################\n\n\n"
        result[0][:add_mutation_type].each do |path|
          puts path
        end
      end

      def migrate_all
        puts "◆◆◆ Let's Auto Generate CRUD API ◆◆◆\n"
        paths = get_tables.map do |class_name|
          migrate class_name: class_name.singularize
        end
        puts "\n============== Model ======================\n\n"
        paths.each do |class_name|
          class_name.each do |path|
            path[:model].each { |line| puts line }
          end
        end
        puts "\n============== Type =======================\n\n"
        paths.each do |class_name|
          class_name.each do |path|
            path[:type].each { |line| puts line }
          end
        end
        puts "\n============== FactoryBot =================\n\n"
        paths.each do |class_name|
          class_name.each do |path|
            path[:rspec_factory].each { |line| puts line }
          end
        end
        puts "\n============== RspecModel =================\n\n"
        paths.each do |class_name|
          class_name.each do |path|
            path[:rspec_model].each { |line| puts line }
          end
        end
        puts "\n============== RspecMutation =================\n\n"
        paths.each do |class_name|
          class_name.each do |path|
            path[:rspec_mutation].each { |line| puts line }
          end
        end
        puts "\n============== RspecQuery =================\n\n"
        paths.each do |class_name|
          class_name.each do |path|
            path[:rspec_query].each { |line| puts line }
          end
        end
        puts "\n============== Query ======================\n\n"
        paths.each do |class_name|
          class_name.each do |path|
            path[:query].each { |line| puts line }
          end
        end
        puts "\n============== Mutation ===================\n\n"
        paths.each do |class_name|
          class_name.each do |path|
            path[:mutation].each { |line| puts line }
          end
        end
        puts "\nAll files created from ./db/schema.rb"
        puts "\n\n"
        puts "\n##########################################################\n"
        puts "#                                                        #\n"
        puts "# Add These Lines at ./app/graphql/types/query_type.rb   #\n"
        puts "#                                                        #\n"
        puts "##########################################################\n\n\n"
        paths.each do |class_name|
          class_name.each do |path|
            path[:add_query_type].each { |line| puts line }
          end
        end
        puts "\n    ## Connection Type\n\n"
        get_tables.each do |class_name|
          puts "    def #{class_name.pluralize}"
          puts "      #{class_name.singularize.camelize}.all.order(id: :desc)"
          puts "    end\n\n"
        end
        puts "\n#############################################################\n"
        puts "#                                                           #\n"
        puts "# Add These Lines at ./app/graphql/types/mutation_type.rb   #\n"
        puts "#                                                           #\n"
        puts "#############################################################\n\n\n"
        paths.each do |class_name|
          class_name.each do |path|
            path[:add_mutation_type].each { |line| puts line }
          end
        end
      end
    end
  end
end
