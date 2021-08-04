require "souls"
Souls.configure do |config|
  config.app = "souls-api"
  config.project_id = "souls-api"
  config.strain = "worker"
  config.worker_endpoint = "https://worker.com"
  config.fixed_gems = ["selenium-webdriver"]
end
