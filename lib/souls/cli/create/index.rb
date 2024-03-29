require_relative "./functions"
module SOULs
  class Create < Thor
    desc "worker [name]", "Create SOULs Worker"
    def worker(name)
      require("#{SOULs.get_mother_path}/config/souls")
      Dir.chdir(SOULs.get_mother_path.to_s) do
        worker_name = "worker-#{name}"
        file_dir = "apps/worker-#{name}"
        raise(StandardError, "Same Worker Already Exist!") if Dir.exist?(file_dir)

        workers = SOULs.configuration.workers
        port = 3000 + workers.size
        download_worker(worker_name:)
        souls_conf_update(worker_name:)
        souls_conf_update(worker_name:, strain: "api")
        workflow(worker_name:)
        procfile(worker_name:, port:)
        mother_procfile(worker_name:)
        souls_config_init(worker_name:)
        system("cd #{file_dir} && bundle")
        system("cd #{file_dir} && mv .env.sample .env")
        souls_worker_credit(worker_name:)
      end
      true
    end

    private

    def procfile(worker_name: "worker-mailer", port: 123)
      file_path = "apps/#{worker_name}/Procfile.dev"
      File.open(file_path, "w") do |f|
        f.write("#{worker_name}: bundle exec puma -p #{port} -e development")
      end
    end

    def mother_procfile(worker_name: "worker-mailer")
      file_path = "Procfile.dev"
      File.open(file_path, "a") do |f|
        f.write("\n#{worker_name}: foreman start -f ./apps/#{worker_name}/Procfile.dev")
      end
    end

    def souls_conf_update(worker_name: "worker-mailer", strain: "mother")
      workers = SOULs.configuration.workers
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
      port: #{port}
    }
  ]
end
      TEXT

      File.open(file_path, "w") { |f| f.write(write_txt) }
    end

    def workflow(worker_name: "worker-mailer")
      file_dir = ".github/workflows"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/#{worker_name}.yml"
      worker_name_camelize = worker_name.gsub("-", "_").camelize
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
              - name: Set up Ruby 3.1
                uses: ruby/setup-ruby@v1
                with:
                  bundler-cache: true
                  ruby-version: 3.1

              - name: Checkout the repository
                uses: actions/checkout@v2

              - id: auth
                uses: google-github-actions/auth@v0
                with:
                  credentials_json: ${{ secrets.SOULS_GCP_SA_KEY }}

              - name: Set up Cloud SDK
                uses: google-github-actions/setup-gcloud@v0

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
                      --set-env-vars="SOULS_GCP_PROJECT_ID=${{ secrets.SOULS_GCP_PROJECT_ID }}" \\
                      --set-env-vars="RUBY_YJIT_ENABLE=1"
        TEXT
      end
      SOULs::Painter.create_file(file_path.to_s)
      file_path
    end

    def souls_config_init(worker_name: "worker-mailer")
      app_name = SOULs.configuration.app
      project_id = SOULs.configuration.project_id
      config_dir = "apps/#{worker_name}/config"
      FileUtils.mkdir_p(config_dir) unless Dir.exist?(config_dir)
      FileUtils.touch("#{config_dir}/souls.rb")
      file_path = "#{config_dir}/souls.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          SOULs.configure do |config|
            config.app = "#{app_name}"
            config.project_id = "#{project_id}"
            config.region = "asia-northeast1"
            config.endpoint = "/endpoint"
            config.strain = "worker"
            config.fixed_gems = ["graphql"]
            config.workers = []
          end
        TEXT
      end
    end

    def download_worker(worker_name: "worker-mailer")
      version = SOULs.get_latest_version_txt(service_name: "worker").join(".")
      file_name = "worker-v#{version}.tgz"
      url = "https://storage.googleapis.com/souls-bucket/boilerplates/workers/#{file_name}"
      puts(url)
      system("curl -OL #{url}")
      system("tar -zxvf ./#{file_name}")
      system("mv ./worker apps/#{worker_name}")
      system("cp ./apps/api/config/database.yml ./apps/#{worker_name}/config/")
      FileUtils.rm_f(file_name)
    end

    def souls_worker_credit(worker_name: "worker-mailer")
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
      ms = Paint % [txt2, :blue, { red1:, red2:, red3:, red4: }]
      puts(ms)
      puts(line)
      welcome = Paint["SOULs Worker is Ready!", :white]
      puts(welcome)
      souls_ver = Paint["SOULs Version: #{SOULs::VERSION}", :white]
      puts(souls_ver)
      puts(line)
      endroll = <<~TEXT
        Easy to Run
        $ cd apps/#{worker_name}
        $ souls s
        Go To : http://localhost:3000

        Doc: https://souls.el-soul.com/
      TEXT
      cd = Paint[endroll, :white]
      puts(cd)
      puts(line)
    end
  end
end
