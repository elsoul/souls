module Souls
  module Init
    class << self
      def get_version repository_name: "souls_api"
        data = JSON.parse `curl \
        -H "Accept: application/vnd.github.v3+json" \
        -s https://api.github.com/repos/elsoul/#{repository_name}/releases`
        data[0]["tag_name"]
      end

      def initial_config_init app_name: "souls", strain: "api"
        FileUtils.touch "./#{app_name}/config/souls.rb"
        file_path = "./#{app_name}/config/souls.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            Souls.configure do |config|
              config.app = "#{app_name}"
              config.strain = "#{strain}"
            end
          EOS
        end
      rescue StandardError => error
        puts error
      end

      def download_souls app_name: "souls", repository_name: "souls_api "
        version = get_version repository_name: repository_name
        system "curl -OL https://github.com/elsoul/#{repository_name}/archive/#{version}.tar.gz"
        system "tar -zxvf ./#{version}.tar.gz"
        system "mkdir #{app_name}"
        folder = version.delete "v"
        system "cp -r #{repository_name}-#{folder}/. #{app_name}/"
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
    end
  end
end
