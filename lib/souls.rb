require_relative "souls/index"
require_relative "souls/cli"
require "active_support/core_ext/string/inflections"
require "date"
require "json"
require "net/http"
require "paint"
require "whirly"
require "tty-prompt"
require "thor"
require "resolv"
require "retryable"
require "google/cloud/pubsub"

module SOULs
  extend SOULs::Utils
  class Error < StandardError; end
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end

  class Configuration
    attr_accessor :app, :strain, :project_id, :region, :endpoint, :fixed_gems, :workers

    def initialize
      @app = nil
      @project_id = nil
      @region = nil
      @endpoint = nil
      @strain = nil
      @fixed_gems = nil
      @workers = nil
    end

    def instance_name
      "souls-#{@app}-db"
    end

    def gcr_region
      if @region.include?("asia")
        "asia.gcr.io"
      elsif @region.include?("eu")
        "eu.gcr.io"
      else
        "gcr.io"
      end
    end

    def gcp_db_host
      "/cloudsql/#{@project_id}:#{@region}:#{instance_name}"
    end
  end
end
