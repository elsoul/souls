FirebaseIdToken.configure do |config|
  config.project_ids = [ENV.fetch("SOULS_FB_PROJECT_ID", nil)]
  config.redis = Redis.new
end
