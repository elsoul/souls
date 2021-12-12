module Souls
  class Upgrade < Thor
    desc "config", "Update config/souls.rb"
    def config
      souls = Souls.configuration
      prompt = TTY::Prompt.new
      regions = `gcloud app regions list | awk '{print $1}'`.split("\n")
      regions.shift
      project_id = prompt.ask("Project ID:", default: souls.project_id)
      region = prompt.select("Region:", regions, default: souls.region)
      endpoint = prompt.ask("Endpoint:", default: souls.endpoint)

      Dir.chdir(Souls.get_mother_path.to_s) do
        mother_conf_path = "config/souls.rb"
        api_conf_path = "apps/api/config/souls.rb"
        mother_conf = File.readlines(mother_conf_path)
        api_conf = File.readlines(api_conf_path)
        mother_conf[2] = "  config.project_id = \"#{project_id}\"\n"
        mother_conf[3] = "  config.region = \"#{region}\"\n"
        mother_conf[4] = "  config.endpoint = \"#{endpoint}\"\n"
        api_conf[2] = "  config.project_id = \"#{project_id}\"\n"
        api_conf[3] = "  config.region = \"#{region}\"\n"
        api_conf[4] = "  config.endpoint = \"#{endpoint}\"\n"
        File.open(mother_conf_path, "w") { |f| f.write(mother_conf.join) }
        File.open(api_conf_path, "w") { |f| f.write(api_conf.join) }
      end
    end
    # rubocop:disable Style/StringHashKeys
    map "conf" => "config"
    # rubocop:enable Style/StringHashKeys
  end
end
