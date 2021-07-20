require "souls"
Souls.configure do |config|
  config.app = "souls-api"
  config.project_id = "souls-api"
  config.strain = "api"
  config.api_repo = "elsoul/souls_api"
  config.worker_repo = "elsoul/souls_worker"
  config.worker_endpoint = "https://worker.com"
  config.fixed_gems = []
end
