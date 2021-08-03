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
      config_dir = "./#{app_name}/apps/#{service_name}/config"
      FileUtils.mkdir_p(config_dir) unless Dir.exist?(config_dir)
      FileUtils.touch("#{config_dir}/souls.rb")
      file_path = "#{config_dir}/souls.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          Souls.configure do |config|
            config.app = "#{app_name}"
            config.project_id = "souls-app"
            config.strain = "#{service_name}"
            config.worker_endpoint = "https://worker.com"
            config.fixed_gems = ["excluded_gem"]
          end
        TEXT
      end
    rescue StandardError => e
      puts(e)
    end

    def self.download_github_actions(app_name: "souls-app")
      file_name = "github.tgz"
      url = "https://storage.googleapis.com/souls-bucket/github_actions/github.tgz"
      system("curl -OL #{url}")
      FileUtils.mkdir("github")
      system("tar -zxvf ./#{file_name} -C #{file_name}/#{app_name}")
      FileUtils.rm(file_name)
    end

    def self.mother_config_init(app_name: "souls-app")
      config_dir = "./#{app_name}/config"
      FileUtils.mkdir_p(config_dir) unless Dir.exist?(config_dir)
      FileUtils.touch("#{config_dir}/souls.rb")
      file_path = "#{config_dir}/souls.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          Souls.configure do |config|
            config.app = "#{app_name}"
            config.project_id = "souls-app"
            config.strain = "mother"
            config.api = true
            config.worker = false
            config.frontend = false
            config.worker_endpoint = ""
            config.fixed_gems = ["excluded_gem"]
          end
        TEXT
      end
    rescue StandardError => e
      puts(e)
    end

    def self.return_method(args)
      strains = %w[api worker console admin media doc].freeze
      app_name = args[1]
      if app_name.nil?
        puts(Paint["you need to specify your app name", :red])
        puts(Paint["`souls new souls-app`", :yellow])
        exit
      end

      prompt = TTY::Prompt.new
      choices = ["1. SOULs GraphQL API", "2. SOULs Pub/Sub Worker", "3. SOULs Frontend Web"]
      choice_num = prompt.select(Paint["Select Strain: ", :cyan], choices)[0].to_i
      case choice_num
      when 1, 2
        service_name = (strains[choice_num.to_i - 1]).to_s
        Souls::Init.download_souls(app_name: app_name, service_name: service_name)
        Souls::Init.mother_config_init(app_name: app_name)
        Souls::Init.download_github_actions(app_name: app_name)
        Souls::Init.initial_config_init(app_name: app_name, service_name: service_name)
      else
        puts(Paint["Coming Soon...", :blue])
      end
    end

    def self.download_souls(app_name: "souls", service_name: "api")
      version = Souls.get_latest_version_txt(service_name: service_name).join(".")
      file_name = "#{service_name}-v#{version}.tgz"
      url = "https://storage.googleapis.com/souls-bucket/boilerplates/#{service_name.pluralize}/#{file_name}"
      system("curl -OL #{url}")
      system("mkdir -p #{app_name}/apps/#{service_name}")
      system("tar -zxvf ./#{file_name} -C #{app_name}/apps/")
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
        $ cd #{app_name}/apps/#{service_name}
        $ bundle
        $ souls s
        Go To : http://localhost:4000

        Doc: https://souls.elsoul.nl
      TEXT
      cd = Paint[endroll, :white]
      puts(cd)
      puts(line)
    end

    def self.download_worker
      current_dir_name = FileUtils.pwd.to_s.match(%r{/([^/]+)/?$})[1]
      version = Souls.get_latest_version_txt(service_name: "worker").join(".")
      file_name = "worker-v#{version}.tgz"
      url = "https://storage.googleapis.com/souls-bucket/boilerplates/workers/#{file_name}"
      system("curl -OL #{url}")
      system("mkdir -p ./apps/worker")
      system("tar -zxvf ./#{file_name} -C ./apps/")
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
      welcome = Paint["SOULs Worker Activated!", :white]
      puts(welcome)
      souls_ver = Paint["SOULs Version: #{Souls::VERSION}", :white]
      puts(souls_ver)
      puts(line)
      endroll = <<~TEXT
        Easy to Run
        $ cd ./apps/worker
        $ bundle
        $ souls model:update
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
