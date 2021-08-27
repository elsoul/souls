require "souls"
Souls.configure do |config|
  config.app = "souls-app"
  config.project_id = "souls-app"
  config.strain = "worker"
  config.fixed_gems = ["selenium-webdriver"]
end
