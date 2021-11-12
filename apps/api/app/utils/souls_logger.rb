module SoulsLogger
  @logger = Google::Cloud::Logging.new(project_id: ENV["SOULS_GCP_PROJECT_ID"])

  def self.critical_log(message)
    entry = write_log(message)
    entry.critical!

    @logger.write_entries entry
  end

  def self.warning_log(message)
    entry = write_log(message)
    entry.warning!

    @logger.write_entries entry
  end

  def self.info_log(message)
    entry = write_log(message)
    entry.info!

    @logger.write_entries entry
  end

  private

  def self.write_log(message)
    entry = @logger.entry
    entry.payload = "#{message.to_s}\n #{message.backtrace.join("\n")}"
    entry.log_name = "error"
    entry.resource.type = "cloud_run_revision"
    entry.resource.labels[:service_name] = "souls"
    entry.resource.labels[:revision_name] = Souls::VERSION

    entry
  end
end
