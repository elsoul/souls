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

    def self.exit_on_failure?
      false
    end
  end
end
