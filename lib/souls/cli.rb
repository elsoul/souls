require "souls"

module Souls
  class CLI < Thor
    desc "api [COMMAND]", "souls api Commands"
    subcommand "api", Api

    desc "gcloud [COMMAND]", "souls gcloud Commands"
    subcommand "gcloud", Gcloud

    desc "docker [COMMAND]", "souls docker Commands"
    subcommand "docker", Docker

    desc "create [COMMAND]", "souls create worker $worker_name"
    subcommand "create", Create

    # rubocop:disable Style/StringHashKeys
    map "c" => :console
    map "s" => :server
    map "db:migrate" => :migrate
    map "db:create_migration" => :create_migration
    map "db:add_column" => :add_column
    map "db:rename_column" => :rename_column
    map "db:change_column" => :change_column
    map "db:remove_column" => :remove_column
    map "db:drop_table" => :drop_table
    map "db:create" => :db_create
    map "db:migrate:reset" => :mirgate_reset
    map "db:seed" => :seed
    # rubocop:enable Style/StringHashKeys
    def self.exit_on_failure?
      false
    end
  end
end
