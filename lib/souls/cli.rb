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
    method_option :all, type: :boolean, aliases: "--all", default: false, desc: "Run (Rspec & steep check & Rubocop)"
    def test
      if options[:all]
        Dir.chdir(SOULs.get_mother_path.to_s) do
          system("steep check")
        end
        Dir.chdir(SOULs.get_api_path.to_s) do
          system("rubocop -A")
          system("bundle exec rspec")
        end
      else
        system("rubocop -A")
        system("bundle exec rspec")
      end
    end

    desc "check", "Run steep check"
    def check
      Dir.chdir(SOULs.get_mother_path.to_s) do
        system("steep check")
      end
    end

    def self.exit_on_failure?
      false
    end
  end
end
