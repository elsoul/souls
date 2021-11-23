module Scaffold
  def self.scaffold_env
    <<~APISCAFFOLD
      SOULS_DB_HOST="/cloudsql/xxxx:asia-northeast1:xxx"
      SOULS_DB_PW=xxxx
      SOULS_DB_USER=postgres
      SOULS_APP_NAME=souls
      SOULS_GCP_PROJECT_ID=xxxx
      SOULS_GCP_REGION=asia-northeast1
      SOULS_GCLOUDSQL_INSTANCE="xx:asia-northeast1:xxx"
      SOULS_SECRET_KEY_BASE="xxx"
      TZ="Asia/Tokyo"
    APISCAFFOLD
  end

  def self.scaffold_env_updated
    <<~APISCAFFOLD
      SOULS_DB_HOST=111.222.333.44
      SOULS_DB_PW=xxxx
      SOULS_DB_USER=postgres
      SOULS_APP_NAME=souls
      SOULS_GCP_PROJECT_ID=xxxx
      SOULS_GCP_REGION=asia-northeast1
      SOULS_GCLOUDSQL_INSTANCE="xx:asia-northeast1:xxx"
      SOULS_SECRET_KEY_BASE="xxx"
      TZ="Asia/Tokyo"
    APISCAFFOLD
  end
end
