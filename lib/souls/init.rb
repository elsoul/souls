module Souls
  module Init
    def self.get_version(repository_name: "souls_api")
      data = JSON.parse(
        `curl \
      -H "Accept: application/vnd.github.v3+json" \
      -s https://api.github.com/repos/elsoul/#{repository_name}/releases`
      )
      data[0]["tag_name"]
    end

    def self.initial_config_init(app_name: "souls", strain: "api")
      FileUtils.touch("./#{app_name}/config/souls.rb")
      file_path = "./#{app_name}/config/souls.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          Souls.configure do |config|
            config.app = "#{app_name}"
            config.project_id = "souls-api"
            config.strain = "#{strain}"
            config.worker_endpoint = "https://worker.com"
            config.fixed_gems = ["excluded_gem"]
          end
        TEXT
      end
    rescue StandardError => e
      puts(e)
    end

    def self.download_souls(app_name: "souls", service_name: "api")
      latest_gem = Souls.get_latest_version(service_name: service_name)
      file_name = latest_gem[:file_url].to_s.match(%r{/([^/]+)/?$})[1]
      system("curl -OL #{latest_gem[:file_url]}")
      system("mkdir -p #{app_name}/#{service_name}")
      system("tar -zxvf ./#{file_name} -C #{app_name}/")
      FileUtils.rm(file_name)
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
      welcome = Paint["Welcome to SOULs!", :white]
      puts(welcome)
      souls_ver = Paint["SOULs Version: #{Souls::VERSION}", :white]
      puts(souls_ver)
      puts(line)
      cd = Paint["Easy to Run\n$ cd #{app_name}/#{service_name}\n$ bundle\n$ souls s\nGo To : http://localhost:3000\n\nDoc: https://souls.elsoul.nl",
                 :white]
      puts(cd)
      puts(line)
    end
  end
end
