Souls.configure do |config|
  config.app = "souls-app"
  config.project_id = "elsoul-nl"
  config.strain = "mother"
  config.github_repo = "elsoul/souls-app"
  config.fixed_gems = []
  config.workers = [
    {
      name: "mailer",
      endpoint: "a",
      local_port: "3001"
    },
    {
      name: "scraper",
      endpoint: "h",
      local_port: "3002"
    }
  ]
end
