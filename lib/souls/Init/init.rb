require "mechanize"

module Souls
  module Init
    class << self
      def create_souls mode: 1, app_name: "souls"
        modes = ["service", "api", "media", "admin"]
        config_needed = (1..2)
        project = {}
        project[:souls_mode] = modes[mode - 1]
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
          download_souls app_name: app_name, repository_name: "souls_#{modes[mode - 1]}"
          config_init app_name: app_name, project: project if config_needed.include?(mode)
        rescue StandardError => error
          puts error
          retry
        end
        puts "Souls All Set!!"
      end

      def config_init app_name: "souls", project: {}
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
      end

      def get_version repository_name: "souls_service"
        agent = Mechanize.new
        page = agent.get("https://github.com/elsoul/#{repository_name}/releases")
        page.search("span.css-truncate-target")[0].to_s.scan(/^*+>(.+)</)[0][0].to_s
      end

      def download_souls app_name: "souls", repository_name: "souls_service"
        version = get_version repository_name: repository_name
        system "curl -OL https://github.com/elsoul/#{repository_name}/archive/#{version}.tar.gz"
        system "tar -zxvf ./#{version}.tar.gz"
        system "mkdir #{app_name}"
        version_file_path = "./#{app_name}/.souls_version"
        File.open(version_file_path, "w") do |f|
          f.write version
        end
        folder = version.delete "v"
        system "cp -r #{repository_name}-#{folder}/* #{app_name}/"
        system "rm -rf #{version}.tar.gz && rm -rf #{repository_name}-#{folder}"
        puts "==="
        puts "Welcome to SOULS!"
        puts "==="
        puts "$ cd #{app_name}"
        puts "---"
      end

    end
  end
end
