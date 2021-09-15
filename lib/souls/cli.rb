require "souls"
require "thor"

module Souls
  # class Gcloud < Thor
  #   desc "pubsub", "Gcloud PubSub Command"
  #   def pubsub
  #     p("pubsub")
  #   end
  # end

  class CLI < Thor
    desc "gcloud [COMMAND]", "souls gcloud Commands"
    subcommand "gcloud", Gcloud

    desc "docker [COMMAND]", "souls docker Commands"
    subcommand "docker", Docker

    map "s" => :hey

    desc "hey", "test task"
    def hey
      p("hey")
    end
  end
end
