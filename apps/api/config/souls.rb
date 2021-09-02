Souls.configure do |config|
  config.app = "souls-app"
  config.project_id = "souls-app"
  config.strain = "api"
  config.fixed_gems = [""]
  config.workers = [
    {
      name: "mailer",
      endpoint: "",
      port: 3000
    }
  ]
end
