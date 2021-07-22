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

    def self.initial_config_init(app_name: "souls", service_name: "api")
      FileUtils.touch("./#{app_name}/#{service_name}/config/souls.rb")
      file_path = "./#{app_name}/#{service_name}/config/souls.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          Souls.configure do |config|
            config.app = "#{app_name}"
            config.project_id = "souls-api"
            config.strain = "#{service_name}"
            config.worker_endpoint = "https://worker.com"
            config.fixed_gems = ["excluded_gem"]
          end
        TEXT
      end
    rescue StandardError => e
      puts(e)
    end

    def self.download_souls(app_name: "souls", service_name: "api")
      version = Souls.get_latest_version_txt(service_name: service_name).join(".")
      file_name = "#{service_name}-v#{version}.tgz"
      url = "https://storage.googleapis.com/souls-bucket/boilerplates/#{service_name.pluralize}/#{file_name}"
      system("curl -OL #{url}")
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
      endroll = <<~TEXT
        Easy to Run
        $ cd #{app_name}/#{service_name}
        $ bundle
        $ souls s
        Go To : http://localhost:3000

        Doc: https://souls.elsoul.nl
      TEXT
      cd = Paint[endroll, :white]
      puts(cd)
      puts(line)
    end
  end
end
