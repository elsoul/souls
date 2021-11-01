require_relative "souls/index"
require_relative "souls/cli"
require "active_support/core_ext/string/inflections"
require "date"
require "json"
require "fileutils"
require "net/http"
require "paint"
require "whirly"
require "tty-prompt"
require "thor"

module Souls
  extend Souls::Utils
  SOULS_METHODS = %w[
    model
    query
    mutation
    type
    resolver
    policy
    rspec_factory
    rspec_model
    rspec_query
    rspec_mutation
    rspec_resolver
    rspec_policy
  ].freeze
  public_constant :SOULS_METHODS
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
  end
end
