require "souls"
Souls.configure do |config|
  config.app = "souls-app"
  config.project_id = "souls-app"
  config.endpoint = "/endpoint"
  config.strain = "worker"
  config.fixed_gems = ["selenium-webdriver"]
end
