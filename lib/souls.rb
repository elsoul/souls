require_relative "souls/version"
require "active_support/core_ext/string/inflections"
require_relative "souls/init"
require_relative "souls/generate"
require_relative "souls/gcloud"
require "json"
require "fileutils"

module Souls
  SOULS_METHODS = [
    "model",
    "query",
    "mutation",
    "type",
    "resolver",
    "policy",
    "rspec_factory",
    "rspec_model",
    "rspec_query",
    "rspec_mutation",
    "rspec_resolver",
    "rspec_policy"
  ]
  class Error < StandardError; end
    class << self
      attr_accessor :configuration

      def run_psql
        system "docker run --rm -d \
          -p 5433:5432 \
          -v postgres-tmp:/var/lib/postgresql/data \
          -e POSTGRES_USER=postgres \
          -e POSTGRES_PASSWORD=postgres \
          -e POSTGRES_DB=souls_test \
          postgres:13-alpine"
        system "docker ps"
      end

      def run_mysql
        system "docker run --rm -d \
          -p 3306:3306 \
          -v mysql-tmp:/var/lib/mysqlql/data \
          -e MYSQL_USER=mysql \
          -e MYSQL_PASSWORD=mysql \
          -e MYSQL_DB=souls_test \
          mysql:latest"
        system "docker ps"
      end

      def run_awake url
        app = Souls.configuration.app
        system "gcloud scheduler jobs create http #{app}-awake --schedule '0,10,20,30,40,50 * * * *' --uri #{url} --http-method GET"
      end
    end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :app, :strain, :project_id, :worker_name, :api_name

    def initialize
      @app = nil
      @project_id = nil
      @strain = nil
      @worker_name = nil
      @api_name = nil
    end
  end
end
