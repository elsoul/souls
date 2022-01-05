module Scaffold
  def self.scaffold_souls
    <<~SOULS
      SOULs.configure do |config|
        config.app = "souls"
        config.project_id = "el-quest"
        config.region = "asia-northeast1"
        config.endpoint = "/endpoint"
        config.strain = "mother"
        config.fixed_gems = ["spring"]
        config.workers = []
      end
    SOULS
  end

  def self.scaffold_souls_updated
    <<~SOULSUPDATED
      SOULs.configure do |config|
        config.app = "souls"
        config.project_id = "el-quest"
        config.region = "asia-northeast1"
        config.endpoint = "/endpoint"
        config.strain = "mother"
        config.fixed_gems = ["spring"]
        config.workers = [
          {
            name: "worker-mailer",
            port: 3000
          }
        ]
      end
    SOULSUPDATED
  end

  def self.scaffold_souls_init
    <<~SOULSINIT
      SOULs.configure do |config|
        config.app = "souls"
        config.project_id = "el-quest"
        config.region = "asia-northeast1"
        config.endpoint = "/endpoint"
        config.strain = "worker"
        config.fixed_gems = ["spring"]
        config.workers = []
      end
    SOULSINIT
  end
end
