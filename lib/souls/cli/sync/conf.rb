module Souls
  module Sync
    class << self
      def conf
        update_conf
        update_conf(strain: "api")
      end

      def update_conf(strain: "mother")
        workers = Souls.configuration.workers
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
              workers.each do |worker|
                endpoint = Souls::Gcloud::Run.get_endpoint(worker_name: worker[:name])
                new_line.write(<<-TEXT)
    {
      name: "#{worker[:name]}",
      endpoint: "#{endpoint}/endpoint",
      port: #{worker[:port]}
    },
                TEXT
              end
              break
            end
          end
          new_line.write(<<-TEXT)
  ]
end
          TEXT
        end
      end
    end
  end
end
