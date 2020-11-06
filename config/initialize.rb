Souls.configure do |config|
  config.project_id = "elsoul2"
  config.app = "grpc-td-cluster"
  config.network = "default"
  config.machine_type = "custom-1-6656"
  config.zone = "us-central1-a"
  config.domain = "el-soul.com"
  config.google_application_credentials = "./config/credentials.json"
end
Souls.configure do |config|
  config.project_id = "d"
  config.app = "d"
  config.network = "d"
  config.machine_type = "d"
  config.zone = "d"
  config.domain = "d"
  config.google_application_credentials = "d"
  config.souls_mode = "API"
end
Souls.configure do |config|
  config.project_id = "elsoul2"
  config.app = "grpc-td-cluster"
  config.network = "default"
  config.machine_type = "custom-1-6656"
  config.zone = "us-central1-a"
  config.domain = "el-soul.com"
  config.google_application_credentials = "./config/credentials.json"
  config.souls_mode = "Service"
end
Souls.configure do |config|
  config.project_id = "sdf"
  config.app = "sdf"
  config.network = "sdf"
  config.machine_type = "sdf"
  config.zone = "sdf"
  config.domain = "sdf"
  config.google_application_credentials = "sdf"
  config.souls_mode = "Client"
end
