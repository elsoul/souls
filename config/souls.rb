Souls.configure do |config|
  config.app = "souls-app"
  config.project_id = "elsoul-nl"
  config.strain = "mother"
  config.fixed_gems = [""]
  config.workers = [
    {
      name: "scraper1",
      endpoint: "",
      port: 3000
    },
    {
      name: "scraper2",
      endpoint: "",
      port: 3001
    },
    {
      name: "scraper3",
      endpoint: "",
      port: 3002
    }
  ]
end
