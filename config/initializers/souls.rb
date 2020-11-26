Souls.configure do |config|
  config.project_id = "el-quest"
  config.app = "el-quest"
  config.namespace = "souls"
  config.service_name = "blog-service"
  config.network = "elsoul"
  config.machine_type = "elsoul"
  config.zone = "elsoul"
  config.domain = "elsoul"
  config.google_application_credentials = "./config/credentials.json"
  config.strain = "service"
  config.proto_package_name = "souls"
end
