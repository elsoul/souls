FirebaseIdToken.configure do |config|
  config.project_ids = ["souls-app"]
  config.redis = Redis.new
end
