module Souls
  module Init
    class << self
      def create_souls mode: 1, app_name: "souls"
        project = {}
        begin
          puts "Google Cloud PROJECT_ID:      (default: elsoul2)"
          project[:project_id] = STDIN.gets.chomp
          project[:project_id] == "" ? project[:project_id] = "elsoul2" : true
          puts "VPC Network Name:          (default: default)"
          project[:network] = STDIN.gets.chomp
          project[:network] == "" ? project[:network] = "default" : true
          puts "Instance MachineType:       (default: custom-1-6656)"
          project[:machine_type] = STDIN.gets.chomp
          project[:machine_type] == "" ? project[:machine_type] = "custom-1-6656" : true
          puts "Zone:           (default: us-central1-a)"
          project[:zone] = STDIN.gets.chomp
          project[:zone] == "" ? project[:zone] = "us-central1-a" : true
          puts "Domain:          (default: el-soul.com)"
          project[:domain] = STDIN.gets.chomp
          project[:domain] == "" ? project[:domain] = "el-soul.com" : true
          puts "Google Application Credentials Path:      (default: #{app_name}/config/credentials.json)"
          project[:google_application_credentials] = STDIN.gets.chomp
          project[:google_application_credentials] == "" ? project[:google_application_credentials] = "./config/credentials.json" : true
          puts project
          puts "Enter to finish set up!"
          confirm = STDIN.gets.chomp
          raise StandardError, "Retry" unless confirm == ""
          project[:souls_mode] =  case mode
                                  when 1
                                    download_souls_service app_name: app_name
                                    irbrc_init app_name: app_name
                                    "Service"
                                  when 2
                                    download_souls_api app_name: app_name
                                    "API"
                                  when "Media"
                                    download_souls_media app_name: app_name
                                    "Media"
                                  else
                                    download_souls_admin app_name: app_name
                                    "Admin"
                                  end
        rescue
          retry
        end
        file_path = "#{app_name}/config/initialize.rb"
        File.open(file_path, "a") do |f|
          f.write <<~EOS
            Souls.configure do |config|
              config.project_id = "#{project[:project_id]}"
              config.app = "#{app_name}"
              config.network = "#{project[:network]}"
              config.machine_type = "#{project[:machine_type]}"
              config.zone = "#{project[:zone]}"
              config.domain = "#{project[:domain]}"
              config.google_application_credentials = "#{project[:google_application_credentials]}"
              config.souls_mode = "#{project[:souls_mode]}"
            end
          EOS
        end
        puts "config at #{app_name}/config/initializer.rb"
        puts "Souls All Set!!"
      end

      def irbrc_init app_name: "souls"
        file_path = "#{app_name}/.irbrc"
        File.open(file_path, "a") do |f|
          f.write <<~EOS
            require "yaml"
            require "erb"
            require "active_record"
            require "logger"

            $LOAD_PATH << "#{Dir.pwd}/app/services"

            Dir[File.expand_path "app/*.rb"].each do |file|
              require file
            end

            db_conf = YAML.safe_load(ERB.new(File.read("./config/database.yml")).result)
            ActiveRecord::Base.establish_connection(db_conf)
            Dir[File.expand_path "./app/controllers/*.rb"].sort.each do |file|
              require file
            end
          EOS
        end
      end

      def download_souls_service app_name: "souls"
        version = "v0.0.1"
        system "curl -OL https://github.com/elsoul/souls_service/archive/#{version}.tar.gz"
        system "tar -zxvf ./#{version}.tar.gz"
        system "mkdir #{app_name}"
        folder = version.delete "v"
        system "cp -r souls_service-#{folder}/* #{app_name}/"
        system "rm -rf #{version}.tar.gz && rm -rf souls_service-#{folder}"
        puts "Welcome to Souls gRPC Service!"
      end

      def download_souls_api app_name: "souls"
        version = "v0.0.1"
        system "curl -OL https://github.com/elsoul/souls_api/archive/#{version}.tar.gz"
        system "tar -zxvf #{version}.tar.gz"
        system "mkdir #{app_name}"
        folder = version.delete "v"
        system "cp -r souls_api-#{folder}/* #{app_name}/"
        system "rm -rf #{version}.tar.gz && rm -rf souls_api-#{folder}"
        puts "Welcome to Souls GraphQL API!"
      end

      def download_souls_media app_name: "souls"
        version = "v0.0.1"
        system "curl -OL https://github.com/elsoul/souls_media/archive/#{version}.tar.gz"
        system "tar -zxvf #{version}.tar.gz"
        system "mkdir #{app_name}"
        folder = version.delete "v"
        system "cp -r souls_media-#{folder}/* #{app_name}/"
        system "rm -rf #{version}.tar.gz && rm -rf souls_media-#{folder}"
        puts "Welcome to Souls Media Web!"
      end

      def download_souls_admin app_name: "souls"
        version = "v0.0.1"
        system "curl -OL https://github.com/elsoul/souls_admin/archive/#{version}.tar.gz"
        system "tar -zxvf #{version}.tar.gz"
        system "mkdir #{app_name}"
        folder = version.delete "v"
        system "cp -r souls_admin-#{folder}/* #{app_name}/"
        system "rm -rf #{version}.tar.gz && rm -rf souls_admin-#{folder}"
        puts "Welcome to Souls Admin Web!"
      end

    end
  end
end
