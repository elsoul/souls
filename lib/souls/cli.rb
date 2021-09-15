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

    desc "db [COMMAND]", "souls db"
    subcommand "db", Db

    # rubocop:disable Style/StringHashKeys
    map "c" => :console
    map "s" => :server
    # rubocop:enable Style/StringHashKeys

    desc "hey", "test task"
    def hey
      p("hey")
    end
  end
end
