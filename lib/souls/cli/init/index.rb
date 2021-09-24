module Souls
  class CLI < Thor
    desc "new [APP_NAME]", "Create SOULs APP"
    def new(app_name)
      if app_name.nil?
        puts(Paint["you need to specify your app name", :red])
        puts(Paint["`souls new souls-app`", :yellow])
        exit
      end

      service_name = "api"
      download_souls(app_name: app_name, service_name: service_name)
      mother_config_init(app_name: app_name)
      download_github_actions(app_name: app_name)
      initial_config_init(app_name: app_name, service_name: service_name)
      souls_api_credit(app_name: app_name, service_name: service_name)
    end

    desc "init", "Run git submodule add RBS collection"
    def add_submodule
      system("git submodule add https://github.com/ruby/gem_rbs_collection.git vendor/rbs/gem_rbs_collection")
    end

    desc "update_submodule", "Run git submodule update --init RBS collection"
    def update_submodule
      system("git submodule update --init https://github.com/ruby/gem_rbs_collection.git vendor/rbs/gem_rbs_collection")
    end

    private

    def get_version(repository_name: "souls_api")
      data = JSON.parse(
        `curl \
        -H "Accept: application/vnd.github.v3+json" \
        -s https://api.github.com/repos/elsoul/#{repository_name}/releases`
      )
      data[0]["tag_name"]
    end

    def generate_cd
      shell = `echo $SHELL`.strip
      rc =
        if shell.include?("zsh")
          "zshrc"
        else
          "bash"
        end
      system("echo '\nalias api=\'cd apps/api\'' >> ~/.#{rc}")
      system("echo 'alias mother=\'...\'' >> ~/.#{rc}")
      system("echo 'alias worker=\'cd apps/worker\'' >> ~/.#{rc}")
      puts(Paint["run `source ~/.#{rc}` to reflect your .#{rc}", :yellow])
      puts(Paint["You can move to mother/api/worker just type", :green])
      puts(Paint["\nmother\n", :white])
      puts(
        Paint["to go back to mother dir from api/worker\n\nYou can also go to api/worker from mother dir by typing",
              :green]
      )
      puts(Paint["\napi\n", :white])
      puts(Paint["or\n", :green])
      puts(Paint["worker", :white])
    end

    def initial_config_init(app_name: "souls", service_name: "api")
      config_dir = "./#{app_name}/apps/#{service_name}/config"
      FileUtils.mkdir_p(config_dir) unless Dir.exist?(config_dir)
      FileUtils.touch("#{config_dir}/souls.rb")
      file_path = "#{config_dir}/souls.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          Souls.configure do |config|
            config.app = "#{app_name}"
            config.project_id = "#{app_name}"
            config.region = "asia-northeast1"
            config.endpoint = "/endpoint"
            config.strain = "api"
            config.fixed_gems = ["spring"]
            config.workers = []
          end
        TEXT
      end
    rescue StandardError => e
      puts(e)
    end

    def download_github_actions(app_name: "souls-app")
      file_name = "github.tgz"
      url = "https://storage.googleapis.com/souls-bucket/boilerplates/github_actions/github.tgz"
      system("curl -OL #{url}")
      FileUtils.mkdir_p("#{app_name}/github")
      system("tar -zxvf ./#{file_name} -C #{app_name}/")
      FileUtils.rm(file_name)
    end

    def mother_config_init(app_name: "souls-app")
      config_dir = "./#{app_name}/config"
      FileUtils.mkdir_p(config_dir) unless Dir.exist?(config_dir)
      FileUtils.touch("#{config_dir}/souls.rb")
      file_path = "#{config_dir}/souls.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          Souls.configure do |config|
            config.app = "#{app_name}"
            config.project_id = "#{app_name}"
            config.region = "asia-northeast1"
            config.endpoint = "/endpoint"
            config.strain = "mother"
            config.fixed_gems = ["spring"]
            config.workers = []
          end
        TEXT
      end
    rescue StandardError => e
      puts(e)
    end

    def download_souls(app_name: "souls", service_name: "api")
      version = Souls.get_latest_version_txt(service_name: service_name).join(".")
      file_name = "#{service_name}-v#{version}.tgz"
      url = "https://storage.googleapis.com/souls-bucket/boilerplates/#{service_name.pluralize}/#{file_name}"
      system("curl -OL #{url}")
      system("mkdir -p #{app_name}/apps/#{service_name}")
      system("tar -zxvf ./#{file_name} -C #{app_name}/apps/")
      FileUtils.rm(file_name)

      sig_name = "sig.tgz"
      url = "https://storage.googleapis.com/souls-bucket/boilerplates/sig/#{sig_name}"
      system("curl -OL #{url}")
      system("tar -zxvf ./#{sig_name} -C #{app_name}")

      system("cd #{app_name} && curl -OL https://storage.googleapis.com/souls-bucket/boilerplates/.rubocop.yml")
      system("cd #{app_name} && curl -OL https://storage.googleapis.com/souls-bucket/boilerplates/Gemfile")
      system("cd #{app_name} && curl -OL https://storage.googleapis.com/souls-bucket/boilerplates/Procfile.dev")
      system("cd #{app_name} && curl -OL https://storage.googleapis.com/souls-bucket/boilerplates/Procfile")
      system("cd #{app_name} && curl -OL https://storage.googleapis.com/souls-bucket/boilerplates/Steepfile")
      FileUtils.rm(sig_name)
    end

    def souls_api_credit(app_name: "souls", service_name: "api")
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
  end
end
