Souls.configure do |config|
  config.app = "souls"
  config.project_id = "elsoul-nl"
  config.strain = "mother"
  config.fixed_gems = [""]
  config.workers = [
    {
      name: "mail1",
      endpoint: "",
      port: 3000
    },
    {
      name: "mail2",
      endpoint: "",
      port: 3001
    },
    {
      name: "mail3",
      endpoint: "",
      port: 3002
    }
  ]
end
