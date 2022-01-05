module SOULs
  class Sync < Thor
    desc "conf", "Sync config/souls.rb Endpoint with Google Cloud Run"
    def conf
      SOULs::Gcloud.new.config_set
      update_conf
      update_conf(strain: "api")
      SOULs::Painter.sync("`config/souls.rb`, `apps/api/config/souls.rb`")
    end

    # rubocop:disable Style/StringHashKeys
    map "config" => "conf"
    # rubocop:enable Style/StringHashKeys

    private

    def update_conf(strain: "mother")
      require("#{SOULs.get_mother_path}/config/souls")
      workers = SOULs.configuration.workers
      Dir.chdir(SOULs.get_mother_path.to_s) do
        file_path = strain == "mother" ? "config/souls.rb" : "apps/api/config/souls.rb"
        new_file_path = "souls.rb"
        worker_switch = false
        File.open(new_file_path, "w") do |new_line|
          File.open(file_path, "r") do |f|
            f.each_line do |line|
              worker_switch = true if line.include?("config.workers")
              next if line.strip == "end"

              new_line.write(line) unless worker_switch

              next unless worker_switch

              new_line.write("  config.workers = [\n")
              workers.each_with_index do |worker, i|
                base_url = SOULs::CloudRun.new.get_endpoint(worker_name: worker[:name])
                endpoint = SOULs.configuration.endpoint
                if (i + 1) == workers.size
                  new_line.write(<<-TEXT)
    {
      name: "#{worker[:name]}",
      endpoint: "#{base_url.strip}#{endpoint}",
      port: #{worker[:port]}
    }
                  TEXT
                else
                  new_line.write(<<-TEXT)
    {
      name: "#{worker[:name]}",
      endpoint: "#{base_url.strip}#{endpoint}",
      port: #{worker[:port]}
    },
                  TEXT
                end
              end
              break
            end
          end
          new_line.write(<<~TEXT)
              ]
            end
          TEXT
        end
        FileUtils.rm(file_path)
        FileUtils.mv(new_file_path, file_path)
      end
    end
  end
end
