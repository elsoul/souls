module Souls
  module Create
    class << self
      def procfile
        workers = Souls.configuration.workers
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
    end
  end
end
