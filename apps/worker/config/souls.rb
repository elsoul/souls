require "souls"
Souls.configure do |config|
  config.app = "souls-app"
  config.project_id = "souls-app"
  config.region = "asia-northeast1"
  config.endpoint = "/endpoint"
  config.strain = "worker"
  config.fixed_gems = ["spring"]
end
