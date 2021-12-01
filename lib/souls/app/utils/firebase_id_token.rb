FirebaseIdToken.configure do |config|
  config.project_ids = [ENV["GCP_PROJECT_ID"]]
end
