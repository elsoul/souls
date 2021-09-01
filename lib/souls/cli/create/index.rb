module Souls
  module Create
    class << self
      def worker(worker_name: "mailer")
        workers = Souls.configuration.workers
        port = 3000 + workers.size
        download_worker(worker_name: worker_name)
        souls_conf_update(worker_name: worker_name)
        souls_conf_update(worker_name: worker_name, strain: "api")
        workflow(worker_name: worker_name)
        procfile(worker_name: worker_name, port: port)
        mother_procfile(worker_name: worker_name)
        souls_config_init(worker_name: worker_name)
      end

      def procfile(worker_name: "mailer", port: 3000)
        file_dir = "apps/#{worker_name}"
        file_path = "#{file_dir}/Procfile.dev"
        File.open(file_path, "w") do |f|
          f.write("web: bundle exec puma -p #{port} -e development")
        end
      end

      def mother_procfile(worker_name: "mailer")
        file_path = "Procfile.dev"
        File.open(file_path, "a") do |f|
          f.write("\n#{worker_name}: foreman start -f ./apps/#{worker_name}/Procfile")
        end
      end

      def souls_conf_update(worker_name: "", strain: "mother")
        workers = Souls.configuration.workers
        port = 3000 + workers.size
        file_path = strain == "mother" ? "config/souls.rb" : "apps/api/config/souls.rb"
        new_file_path = "souls.rb"
        worker_switch = false
        File.open(new_file_path, "w") do |new_line|
          File.open(file_path, "r") do |f|
            f.each_line do |line|
              worker_switch = true if line.include?("config.workers")
              next if line.strip == "end"

              new_line.write(line) unless worker_switch

              next unless worker_switch

              new_line.write("  config.workers = [\n")
              workers.each do |worker|
                new_line.write(<<-TEXT)
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
          new_line.write(<<-TEXT)
    {
      name: "#{worker_name}",
      endpoint: "",
      port: #{port}
    }
  ]
end
          TEXT
        end
        FileUtils.rm(file_path)
        FileUtils.mv(new_file_path, file_path)
      end

      def workflow(worker_name: "")
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
                  - master
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
                  uses: actions/setup-ruby@v1
                  with:
                    ruby-version: 3.0
                - name: Build and test with Rake
                  env:
                    PGHOST: 127.0.0.1
                    PGUSER: postgres
                    RACK_ENV: test
                  run: |
                    sudo apt-get -yqq install libpq-dev
                    cd apps/worker
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
                    project_id: ${{ secrets.GCP_PROJECT_ID }}
                    service_account_key: ${{ secrets.GCP_SA_KEY }}
                    export_default_credentials: true

                - name: Configure Docker
                  run: gcloud auth configure-docker --quiet

                - name: Build Docker container
                  run: docker build -f ./apps/#{worker_name}/Dockerfile ./apps/#{worker_name} -t gcr.io/${{ secrets.GCP_PROJECT_ID }}/${{secrets.APP_NAME}}-#{worker_name}

                - name: Push to Container Resistory
                  run: docker push gcr.io/${{ secrets.GCP_PROJECT_ID }}/${{secrets.APP_NAME}}-#{worker_name}

                - name: Deploy to Cloud Run
                  run: |
                      gcloud run deploy ${{ secrets.APP_NAME }}-#{worker_name} \\
                        --service-account=${{ secrets.APP_NAME }}@${{ secrets.GCP_PROJECT_ID }}.iam.gserviceaccount.com \\
                        --image=gcr.io/${{ secrets.GCP_PROJECT_ID }}/${{secrets.APP_NAME}}-#{worker_name} \\
                        --memory=4Gi \\
                        --region=asia-northeast1 \\
                        --allow-unauthenticated \\
                        --platform=managed \\
                        --quiet \\
                        --concurrency=80 \\
                        --port=8080 \\
                        --set-cloudsql-instances=${{ secrets.GCLOUDSQL_INSTANCE }} \\
                        --set-env-vars="DB_USER=${{ secrets.DB_USER }}" \\
                        --set-env-vars="DB_PW=${{ secrets.DB_PW }}" \\
                        --set-env-vars="DB_HOST=${{ secrets.DB_HOST }}" \\
                        --set-env-vars="TZ=${{ secrets.TZ }}" \\
                        --set-env-vars="SLACK=${{ secrets.SLACK }}" \\
                        --set-env-vars="SECRET_KEY_BASE=${{ secrets.SECRET_KEY_BASE }}" \\
                        --set-env-vars="PROJECT_ID=${{ secrets.GCP_PROJECT_ID }}"
          TEXT
        end
        puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
        file_path
      rescue StandardError => e
        raise(StandardError, e)
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
              config.strain = "worker"
              config.fixed_gems = ["excluded_gem"]
              config.workers = []
            end
          TEXT
        end
      rescue StandardError => e
        puts(e)
      end

      def download_worker(worker_name: "mailer")
        raise(StandardError, "Can't use `worker` for worker. Change Name.") if worker_name == "worker"

        current_dir_name = FileUtils.pwd.to_s.match(%r{/([^/]+)/?$})[1]
        wrong_dir = %w[apps api worker]
        if wrong_dir.include?(current_dir_name)
          raise(StandardError, "You are at wrong directory!Go to Mother Directory!")
        end

        version = Souls.get_latest_version_txt(service_name: "worker").join(".")
        file_name = "worker-v#{version}.tgz"
        url = "https://storage.googleapis.com/souls-bucket/boilerplates/workers/#{file_name}"
        system("curl -OL #{url}")
        system("tar -zxvf ./#{file_name} -C ./apps/")
        system("mv apps/worker apps/#{worker_name}")
        system("cp ./apps/api/config/database.yml ./apps/#{worker_name}/config/")
        FileUtils.rm(file_name)
      end
    end
  end
end
