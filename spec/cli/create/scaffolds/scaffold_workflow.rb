module Scaffold
  def self.scaffold_workflow
    <<~WORKFLOW
      name: WorkerMailer

      on:
        push:
          branches:
            - main
          paths:
            - "apps/worker-mailer/**"
            - ".github/workflows/worker-mailer.yml"

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
              ruby-version: 3.1

          - name: Checkout the repository
            uses: actions/checkout@v2

          - name: GCP Authenticate
            uses: google-github-actions/setup-gcloud@master
            with:
              version: "323.0.0"
              project_id: ${{ secrets.SOULS_GCP_PROJECT_ID }}
              service_account_key: ${{ secrets.SOULS_GCP_SA_KEY }}
              export_default_credentials: true

          - name: Build and test with Rake
            env:
              PGHOST: 127.0.0.1
              PGUSER: postgres
              RACK_ENV: test
              SOULS_GCP_PROJECT_ID: ${{ secrets.SOULS_GCP_PROJECT_ID }}
            run: |
              sudo apt-get -yqq install libpq-dev
              cd apps/worker-mailer
              gem install bundler
              bundle install --jobs 4 --retry 3
              bundle exec rake db:create RACK_ENV=test
              bundle exec rake db:migrate RACK_ENV=test
              bundle exec rspec

          - name: Sync PubSub
            run: cd apps/worker-mailer && souls sync pubsub

          - name: Sync Tasks
            run: cd apps/worker-mailer && souls gcloud scheduler sync_schedules --timezone=${{ secrets.TZ }}

          - name: Configure Docker
            run: gcloud auth configure-docker --quiet

          - name: Build Docker container
            run: docker build -f ./apps/worker-mailer/Dockerfile ./apps/worker-mailer -t gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-worker-mailer

          - name: Push to Container Resistory
            run: docker push gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-worker-mailer

          - name: Deploy to Cloud Run
            run: |
                gcloud run deploy souls-${{ secrets.SOULS_APP_NAME }}-worker-mailer \\
                  --service-account=${{ secrets.SOULS_APP_NAME }}@${{ secrets.SOULS_GCP_PROJECT_ID }}.iam.gserviceaccount.com \\
                  --image=gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-worker-mailer \\
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
                  --set-env-vars="TZ=${{ secrets.TZ }}" \\
                  --set-env-vars="SOULS_SECRET_KEY_BASE=${{ secrets.SOULS_SECRET_KEY_BASE }}" \\
                  --set-env-vars="SOULS_PROJECT_ID=${{ secrets.SOULS_GCP_PROJECT_ID }}"
    WORKFLOW
  end
end
