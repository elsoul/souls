FirebaseIdToken.configure do |config|
  config.project_ids = ["souls"]
  config.redis = Redis.new
end
