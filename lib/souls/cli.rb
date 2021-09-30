require "souls"
module Souls
  class CLI < Thor
    desc "generate [COMMAND]", "SOULs Generate Commands"
    subcommand "generate", Generate

    desc "update [COMMAND]", "SOULs Update Commands"
    subcommand "update", Update

    desc "create [COMMAND]", "SOULs Create Worker"
    subcommand "create", Create

    desc "db [COMMAND]", "SOULs DB Commands"
    subcommand "db", DB

    desc "docker [COMMAND]", "SOULs Docker Commands"
    subcommand "docker", Docker

    desc "gcloud [COMMAND]", "SOULs Gcloud Commands"
    subcommand "gcloud", Gcloud

    desc "sync", " SOULs Sync Commands"
    subcommand "sync", Sync

    desc "upgrade gemfile", "SOULs Upgrade Gemfile & Gemfile.lock"
    subcommand "upgrade", Upgrade

    # rubocop:disable Style/StringHashKeys
    map "c" => :console
    map "s" => :server
    map "g" => :generate
    map "t" => :test
    map ["-v", "--v", "--version", "-version"] => :version
    # rubocop:enable Style/StringHashKeys

    desc "version", "SOULs Version"
    def version
      puts(Souls::VERSION)
    end

    desc "test", "Run Rspec & Rubocop"
    def test
      system("rubocop -A")
      system("bundle exec rspec")
    end

    desc "test_all", "Run (Rspec & steep check & Rubocop)"
    def test_all
      Dir.chdir(Souls.get_mother_path.to_s) do
        system("steep check")
      end
      system("rubocop -A")
      system("bundle exec rspec")
    end

    desc "check", "Run steep check"
    def check
      system("steep check")
    end

    def self.exit_on_failure?
      false
    end
  end
end
