module Souls
  module SoulsLogger
    class Configuration
      attr_accessor :logger

      def initialize
        @logger = nil
      end
    end

    class << self
      attr_writer :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end

    def self.critical_log(message)
      entry = write_log(message)
      entry.critical!

      configuration.logger.write_entries(entry)
    end

    def self.warning_log(message)
      entry = write_log(message)
      entry.warning!

      configuration.logger.write_entries(entry)
    end

    def self.info_log(message)
      entry = write_log(message)
      entry.info!

      configuration.logger.write_entries(entry)
    end

    def self.write_log(message)
      entry = configuration.logger.entry
      entry.payload = "#{message}\n #{message.backtrace.join("\n")}"
      entry.log_name = "error"
      entry.resource.type = "cloud_run_revision"
      entry.resource.labels[:service_name] = "souls"
      entry.resource.labels[:revision_name] = Souls::VERSION

      entry
    end
  end
end
