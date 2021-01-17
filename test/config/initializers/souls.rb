Souls.configure do |config|
  config.project_id = "elsoul2"
  config.app = "blog"
  config.network = "elsoul"
  config.machine_type = "custom-1-6656"
  config.zone = "asia-northeast1-b"
  config.domain = "blog.el-soul.com"
  config.google_application_credentials = "./config/credentials.json"
  config.strain = "service"
  config.proto_package_name = "souls"
end
