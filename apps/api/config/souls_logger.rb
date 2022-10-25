SOULs::SOULsLogger.configure do |config|
  if ENV["RACK_ENV"] == "production"
    config.logger = Google::Cloud::Logging.new(project_id: ENV.fetch("SOULS_GCP_PROJECT_ID", nil))
  end
end
