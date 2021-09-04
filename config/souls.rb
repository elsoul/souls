Souls.configure do |config|
  config.app = "souls"
  config.project_id = "elsoul-nl"
  config.strain = "mother"
  config.fixed_gems = [""]
  config.workers = [{ name: "scraper1", endpoint: "https://souls.com", port: 3000 }]
end
