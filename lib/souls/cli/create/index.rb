module Souls
  class Create < Thor
    desc "worker", "Create SOULs Worker"
    method_option :name, aliases: "--name", desc: "Worker Name", required: true
    def worker
      require("#{Souls.get_mother_path}/config/souls")
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "apps/#{options[:name]}"
        raise(StandardError, "Same Worker Already Exist!") if Dir.exist?(file_dir)

        workers = Souls.configuration.workers
        app = Souls.configuration.app
        port = 3000 + workers.size
        souls_worker_name = "souls-#{app}-#{options[:name]}"
        download_worker(worker_name: options[:name])
        souls_conf_update(worker_name: souls_worker_name)
        souls_conf_update(worker_name: souls_worker_name, strain: "api")
        workflow(worker_name: options[:name])
        procfile(worker_name: options[:name], port: port)
        mother_procfile(worker_name: options[:name])
        souls_config_init(worker_name: options[:name])
        steepfile(worker_name: options[:name])
        souls_helper_rbs(worker_name: options[:name])
        system("cd apps/#{options[:name]} && bundle")
        souls_worker_credit(worker_name: options[:name])
      end
      true
    end

    private

    def steepfile(worker_name: "mailer")
      file_path = "./Steepfile"

      write_txt = ""
      File.open(file_path, "r") do |f|
        f.each_line do |line|
          if line.strip.to_s == "end"
            ["app", "db/seeds.rb", "constants", "app.rb"].each do |path|
              write_txt += "  check \"apps/#{worker_name}/#{path}\"\n"
            end
            write_txt += "end\n"
          else
            write_txt += line
          end
        end
      end
      File.open(file_path, "w") { |f| f.write(write_txt) }
    end

    def procfile(worker_name: "mailer", port: 123)
      file_path = "apps/#{worker_name}/Procfile.dev"
      File.open(file_path, "w") do |f|
        f.write("#{worker_name}: bundle exec puma -p #{port} -e development")
      end
    end

    def mother_procfile(worker_name: "mailer")
      file_path = "Procfile.dev"
      File.open(file_path, "a") do |f|
        f.write("\n#{worker_name}: foreman start -f ./apps/#{worker_name}/Procfile.dev")
      end
    end

    def souls_conf_update(worker_name: "mailer", strain: "mother")
      workers = Souls.configuration.workers
      port = 3000 + workers.size
      file_path = strain == "mother" ? "config/souls.rb" : "apps/api/config/souls.rb"

      write_txt = ""
      File.open(file_path, "r") do |f|
        f.each_line do |line|
          worker_switch = line.include?("config.workers")
          next if line.strip == "end"

          unless worker_switch
            write_txt += line
            next
          end

          write_txt += "  config.workers = [\n"
          workers.each do |worker|
            write_txt += <<-TEXT
    {
      name: "#{worker[:name]}",
      endpoint: "#{worker[:endpoint]}",
      port: #{worker[:port]}
    },
            TEXT
          end
          break
        end
      end
      write_txt += <<-TEXT
    {
      name: "#{worker_name}",
      endpoint: "",
      port: #{port}
    }
  ]
end
      TEXT

      File.open(file_path, "w") { |f| f.write(write_txt) }
    end

    def workflow(worker_name: "mailer")
      file_dir = ".github/workflows"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/#{worker_name}.yml"
      worker_name = worker_name.underscore
      worker_name_camelize = worker_name.camelize
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          name: #{worker_name_camelize}

          on:
            push:
              branches:
                - main
              paths:
                - "apps/#{worker_name}/**"
                - ".github/workflows/#{worker_name}.yml"

          jobs:
            build:

              runs-on: ubuntu-20.04

              services:
                db:
                  image: postgres:13
                  ports: ["5433:5432"]
                  env:
                    POSTGRES_PASSWORD: postgres
                  options: >-
                    --health-cmd pg_isready
                    --health-interval 10s
                    --health-timeout 5s
                    --health-retries 5

              steps:
              - uses: actions/checkout@v2
              - name: Set up Ruby 3.0
                uses: ruby/setup-ruby@v1
                with:
                  ruby-version: 3.0
                  bundler-cache: true
              - name: Build and test with Rake
                env:
                  PGHOST: 127.0.0.1
                  PGUSER: postgres
                  RACK_ENV: test
                run: |
                  sudo apt-get -yqq install libpq-dev
                  cd apps/#{worker_name}
                  gem install bundler
                  bundle install --jobs 4 --retry 3
                  bundle exec rake db:create RACK_ENV=test
                  bundle exec rake db:migrate RACK_ENV=test
                  bundle exec rspec

              - name: Checkout the repository
                uses: actions/checkout@v2

              - name: GCP Authenticate
                uses: google-github-actions/setup-gcloud@master
                with:
                  version: "323.0.0"
                  project_id: ${{ secrets.SOULS_GCP_PROJECT_ID }}
                  service_account_key: ${{ secrets.SOULS_GCP_SA_KEY }}
                  export_default_credentials: true

              - name: Configure Docker
                run: gcloud auth configure-docker --quiet

              - name: Build Docker container
                run: docker build -f ./apps/#{worker_name}/Dockerfile ./apps/#{worker_name} -t gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-#{worker_name}

              - name: Push to Container Resistory
                run: docker push gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-#{worker_name}

              - name: Deploy to Cloud Run
                run: |
                    gcloud run deploy souls-${{ secrets.SOULS_APP_NAME }}-#{worker_name} \\
                      --service-account=${{ secrets.SOULS_APP_NAME }}@${{ secrets.SOULS_GCP_PROJECT_ID }}.iam.gserviceaccount.com \\
                      --image=gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-#{worker_name} \\
                      --memory=4Gi \\
                      --region=${{ secrets.SOULS_GCP_REGION }} \\
                      --allow-unauthenticated \\
                      --platform=managed \\
                      --quiet \\
                      --concurrency=80 \\
                      --port=8080 \\
                      --set-cloudsql-instances=${{ secrets.SOULS_GCLOUDSQL_INSTANCE }} \\
                      --set-env-vars="SOULS_DB_USER=${{ secrets.SOULS_DB_USER }}" \\
                      --set-env-vars="SOULS_DB_PW=${{ secrets.SOULS_DB_PW }}" \\
                      --set-env-vars="SOULS_DB_HOST=${{ secrets.SOULS_DB_HOST }}" \\
                      --set-env-vars="SOULS_TZ=${{ secrets.SOULS_TZ }}" \\
                      --set-env-vars="SOULS_SECRET_KEY_BASE=${{ secrets.SOULS_SECRET_KEY_BASE }}" \\
                      --set-env-vars="SOULS_PROJECT_ID=${{ secrets.SOULS_GCP_PROJECT_ID }}"
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    end

    def souls_config_init(worker_name: "mailer")
      app_name = Souls.configuration.app
      project_id = Souls.configuration.project_id
      config_dir = "apps/#{worker_name}/config"
      FileUtils.mkdir_p(config_dir) unless Dir.exist?(config_dir)
      FileUtils.touch("#{config_dir}/souls.rb")
      file_path = "#{config_dir}/souls.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          Souls.configure do |config|
            config.app = "#{app_name}"
            config.project_id = "#{project_id}"
            config.region = "asia-northeast1"
            config.endpoint = "/endpoint"
            config.strain = "worker"
            config.fixed_gems = ["spring"]
            config.workers = []
          end
        TEXT
      end
    rescue StandardError => e
      puts(e)
    end

    def souls_helper_rbs(worker_name: "mailer")
      file_dir = "./sig/#{worker_name}/app/utils"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/souls_helper.rbs"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module SoulsHelper
            def self.export_csv: (untyped model_name) -> (String? | StandardError )
            def self.export_model_to_csv: (untyped model_name) -> (untyped | StandardError )
            def self.upload_to_gcs: (String file_path, String upload_path) -> untyped
            def self.get_selenium_driver: (?:chrome mode) -> untyped
          end
          module CSV
            def self.open: (*untyped){(untyped) -> nil} -> untyped
          end
          module Selenium
            module WebDriver
              def self.for: (*untyped) -> untyped
              module Chrome
                module Options
                  def self.new: ()-> untyped
                end
              end
              module Remote
                module Capabilities
                  def self.firefox: ()-> untyped
                end
              end
            end
          end
          module Google
            module Cloud
              module Storage
                def self.new: ()-> untyped
              end
            end
          end
        TEXT
      end
    end

    def download_worker(worker_name: "mailer")
      version = Souls.get_latest_version_txt(service_name: "worker").join(".")
      file_name = "worker-v#{version}.tgz"
      url = "https://storage.googleapis.com/souls-bucket/boilerplates/workers/#{file_name}"
      system("curl -OL #{url}")
      system("tar -zxvf ./#{file_name}")
      system("mv ./worker apps/#{worker_name}")
      system("cp ./apps/api/config/database.yml ./apps/#{worker_name}/config/")
      FileUtils.rm(file_name)
    end

    def souls_worker_credit(worker_name: "mailer")
      line = Paint["====================================", :yellow]
      puts("\n")
      puts(line)
      txt2 = <<~TEXT
           _____ ____  __  ____#{'        '}
          / ___// __ \\/ / / / /   %{red1}
          \\__ \\/ / / / / / / /   %{red2}
          __/ / /_/ / /_/ / /___%{red3}#{' '}
        /____/\\____/\\____/_____%{red4}#{'  '}
      TEXT
      red1 = ["_____", :red]
      red2 = ["/ ___/", :red]
      red3 = ["(__  )", :red]
      red4 = ["/____/", :red]
      ms = Paint % [txt2, :blue, { red1: red1, red2: red2, red3: red3, red4: red4 }]
      puts(ms)
      puts(line)
      welcome = Paint["SOULs Worker is Ready!", :white]
      puts(welcome)
      souls_ver = Paint["SOULs Version: #{Souls::VERSION}", :white]
      puts(souls_ver)
      puts(line)
      endroll = <<~TEXT
        Easy to Run
        $ cd apps/#{worker_name}
        $ souls sync model
        $ souls s
        Go To : http://localhost:3000/playground

        Doc: https://souls.elsoul.nl
      TEXT
      cd = Paint[endroll, :white]
      puts(cd)
      puts(line)
    end
  end
end
