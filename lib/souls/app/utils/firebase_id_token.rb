FirebaseIdToken.configure do |config|
  config.project_ids = [ENV["SOULS_GCP_PROJECT_ID"]]
end
