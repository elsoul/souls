require "souls"
module SOULs
  class CLI < Thor
    desc "generate [COMMAND]", "SOULs Generate Commands"
    subcommand "generate", Generate

    desc "github [COMMAND]", "SOULs Github Commands"
    subcommand "github", Github

    desc "update [COMMAND]", "SOULs Update Commands"
    subcommand "update", Update

    desc "create [COMMAND]", "SOULs Create Worker"
    subcommand "create", Create

    desc "db [COMMAND]", "SOULs DB Commands"
    subcommand "db", DB

    desc "delete [COMMAND]", "SOULs Delete Commands"
    subcommand "delete", Delete

    desc "docker [COMMAND]", "SOULs Docker Commands"
    subcommand "docker", Docker

    desc "gcloud [COMMAND]", "SOULs Gcloud Commands"
    subcommand "gcloud", Gcloud

    desc "sync", " SOULs Sync Commands"
    subcommand "sync", Sync

    desc "upgrade [COMMAND]", "SOULs Upgrade Commands"
    subcommand "upgrade", Upgrade

    desc "functions [COMMAND]", "SOULs functions Commands"
    subcommand "functions", Functions

    # rubocop:disable Style/StringHashKeys
    map "c" => :console
    map "s" => :server
    map "g" => :generate
    map "gh" => :github
    map "t" => :test
    map "d" => :delete
    map ["-v", "--v", "--version", "-version"] => :version
    # rubocop:enable Style/StringHashKeys

    desc "version", "SOULs Version"
    def version
      puts(SOULs::VERSION)
    end

    desc "test", "Run Rspec & Rubocop"
    def test
      system("rubocop -A")
      system("bundle exec rspec")
    end

    desc "build", "Run Docker Build"
    def build
      app = SOULs.configuration.app
      system("docker build . -t #{app}")
    end

    desc "tag", "Run Docker Tag"
    def tag
      souls_config = SOULs.configuration
      app = souls_config.app
      region = souls_config.region
      gcr = region_to_container_url(region:)
      project_id = souls_config.project_id
      system("docker tag #{app}:latest #{gcr}/#{project_id}/#{app}:latest")
    end

    desc "push", "Run Docker Push"
    def push
      souls_config = SOULs.configuration
      app = souls_config.app
      region = souls_config.region
      gcr = region_to_container_url(region:)
      project_id = souls_config.project_id
      system("docker push #{gcr}/#{project_id}/#{app}:latest")
    end

    def deploy
      souls_config = SOULs.configuration
      app = souls_config.app
      region = souls_config.region
      gcr = region_to_container_url(region:)
      project_id = souls_config.project_id
      system(
        "gcloud beta run deploy #{app} \
        --image #{gcr}/#{project_id}/#{app}:latest \
        --memory=4Gi \
        --cpu=2 \
        --quiet \
        --region=#{region} \
        --allow-unauthenticated \
        --platform=managed \
        --no-cpu-throttling \
        --set-cloudsql-instances=#{project_id}:#{region}:#{instance_name} \
        --port=8080 \
        --project=#{app} \
        --set-env-vars='DB_USER=#{db_user}' \
        --set-env-vars='DB_HOST=#{db_ip}' \
        --set-env-vars='DB_NAME=#{db_name}' \
        --set-env-vars='DB_PW=#{db_pw}' \
        --set-env-vars='RACK_ENV=production' \
        --set-env-vars='RUBY_YJIT_ENABLE=1' \
        --set-env-vars='TZ=#{tz}' \
        --set-env-vars='SOULS_SECRET_KEY_BASE=sokk'"
      )
    end

    def region_to_container_url(region: "asia-northeast1")
      if region.include?("asia")
        "asia.gcr.io"
      elsif region.include?("europe")
        "eu.gcr.io"
      else
        "gcr.io"
      end
    end

    def self.exit_on_failure?
      false
    end
  end
end
