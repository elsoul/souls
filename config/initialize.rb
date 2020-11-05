Souls.configure do |config|
  config.project_id = "elsoul2"
  config.app = "grpc-td-cluster"
  config.network = "default"
  config.machine_type = "custom-1-6656"
  config.zone = "us-central1-a"
  config.domain = "el-soul.com"
  config.google_application_credentials = "./config/credentials.json"
end
