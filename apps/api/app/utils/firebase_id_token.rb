FirebaseIdToken.configure do |config|
  config.project_ids = [ENV["SOULS_GCP_PROJECT_ID"]]
  config.redis = Redis.new
end
