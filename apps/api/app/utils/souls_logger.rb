Souls::SoulsLogger.configure do |config|
  config.logger = Google::Cloud::Logging.new(project_id: ENV["SOULS_GCP_PROJECT_ID"]) if ENV["RACK_ENV"] == "production"
end
