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
                  --set-env-vars="SOULS_GCP_PROJECT_ID=${{ secrets.SOULS_GCP_PROJECT_ID }}" \\
                  --set-env-vars="RUBY_YJIT_ENABLE=1"
    WORKFLOW
  end
end
