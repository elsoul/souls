module SOULs
  class CLI < Thor
    def initialize(*_args)
      super
      @bucket_url = "https://storage.googleapis.com/souls-bucket/boilerplates/#{SOULs::VERSION}"
    end

    desc "new [APP_NAME]", "Create SOULs APP"
    def new(app_name)
      if app_name.nil?
        puts(Paint["you need to specify your app name", :red])
        puts(Paint["`souls new souls-app`", :yellow])
        exit
      end
      file_dir = "./#{app_name}"
      if Dir.exist?(file_dir) && !Dir.empty?(file_dir)
        SOULs::Painter.error("Directory already exists and is not empty")
        return
      end

      service_name = "api"
      download_souls(app_name:, service_name:)
      mother_config_init(app_name:)
      download_github_actions(app_name:)
      initial_config_init(app_name:, service_name:)
      system("cd #{app_name}/apps/api && mv .env.sample .env")
      system("cd #{app_name} && git init --initial-branch=main")
      system("cd #{app_name} && rbs collection init && rbs collection install")
      souls_api_credit(app_name)
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
          SOULs.configure do |config|
            config.app = "#{app_name}"
            config.project_id = "#{app_name}"
            config.region = "asia-northeast1"
            config.endpoint = "/endpoint"
            config.strain = "api"
            config.fixed_gems = ["spring", "grpc"]
            config.workers = []
          end
        TEXT
      end
    rescue StandardError => e
      puts(e)
    end

    def download_github_actions(app_name: "souls-app")
      file_name = "github.tgz"
      url = "#{@bucket_url}/github_actions/github.tgz"
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
          SOULs.configure do |config|
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

    def get_latest_gem(app_name)
      file_path = "./#{app_name}/Gemfile"
      souls_gem = "gem \"souls\", \"#{SOULs::VERSION}\""
      souls_gem = "gem \"souls\", \"#{SOULs::VERSION}\", path: \"~/.local_souls/\"" if SOULs::VERSION.length > 20
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          source "https://rubygems.org"

          gem "activesupport", "7.0.2.3"
          gem "foreman", "0.87.2"
          gem "google-cloud-pubsub", "2.9.1"
          gem "paint", "2.2.1"
          gem "parser", "3.1.1.0"
          gem "pg", "1.3.2"
          gem "rake", "13.0.6"
          gem "rspec", "3.10.0"
          gem "rubocop", "1.26.0"
          gem "sinatra-activerecord", "2.0.25"
          gem "solargraph", "0.44.3"
          #{souls_gem}
          gem "steep", "0.49.0"
          gem "thor", "1.2.1"
          gem "tty-prompt", "0.23.1"
          gem "whirly", "0.3.0"
        TEXT
      end
    rescue StandardError => e
      puts(e)
    end

    def download_souls(app_name: "souls", service_name: "api")
      version = SOULs.get_latest_version_txt(service_name:).join(".")
      file_name = "#{service_name}-v#{version}.tgz"
      url = "https://storage.googleapis.com/souls-bucket/boilerplates/#{service_name.pluralize}/#{file_name}"
      system("curl -OL #{url}")
      system("mkdir -p #{app_name}/apps/#{service_name}")
      system("tar -zxvf ./#{file_name} -C #{app_name}/apps/")
      FileUtils.rm(file_name)

      sig_name = "sig.tgz"
      url = "#{@bucket_url}/sig/#{sig_name}"
      system("curl -OL #{url}")
      system("tar -zxvf ./#{sig_name} -C #{app_name}")

      system("cd #{app_name} && curl -OL #{@bucket_url}/.rubocop.yml")
      get_latest_gem(app_name)
      system("cd #{app_name} && curl -OL #{@bucket_url}/Procfile.dev")
      system("cd #{app_name} && curl -OL #{@bucket_url}/Procfile")
      system("cd #{app_name} && curl -OL #{@bucket_url}/Steepfile")
      system("cd #{app_name} && curl -OL #{@bucket_url}/gitignore")
      system("cd #{app_name} && mv gitignore .gitignore")
      system("cd #{app_name} && bundle")
      system("cd #{app_name}/apps/api && bundle")
      FileUtils.rm(sig_name)
    end

    def souls_api_credit(app_name)
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
      ms = Paint % [txt2, :cyan, { red1:, red2:, red3:, red4: }]
      puts(ms)
      puts(line)
      welcome = Paint["Welcome to SOULs!", :white]
      puts(welcome)
      souls_ver = Paint["SOULs Version: #{SOULs::VERSION}", :white]
      puts(souls_ver)
      puts(line)
      endroll = <<~TEXT
        Easy to Run
        $ cd #{app_name}/apps/api
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
