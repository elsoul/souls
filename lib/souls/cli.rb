require "souls"
module Souls
  class CLI < Thor
    desc "api [COMMAND]", "SOULs API Commands"
    subcommand "api", API

    desc "gcloud [COMMAND]", "SOULs Gcloud Commands"
    subcommand "gcloud", Gcloud

    desc "docker [COMMAND]", "SOULs Docker Commands"
    subcommand "docker", Docker

    desc "create [COMMAND]", "SOULs Create Worker"
    subcommand "create", Create

    desc "sync", " SOULs Sync Commands"
    subcommand "sync", Sync

    desc "upgrade", "SOULs Upgrade Commands"
    subcommand "upgrade", Upgrade

    desc "worker [COMMAND]", "SOULs Worker Commands"
    subcommand "worker", Worker

    # rubocop:disable Style/StringHashKeys
    map "c" => :console
    map "s" => :server
    map "db:migrate:reset" => :migrate_reset
    map "db:migrate" => :migrate
    map "db:create_migration" => :create_migration
    map "db:add_column" => :add_column
    map "db:rename_column" => :rename_column
    map "db:change_column" => :change_column
    map "db:remove_column" => :remove_column
    map "db:drop_table" => :drop_table
    map "db:create" => :db_create
    map "db:seed" => :seed
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

    def self.exit_on_failure?
      false
    end
  end
end
