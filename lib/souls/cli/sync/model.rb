module Souls
  class Sync < Thor
    # rubocop:disable Style/StringHashKeys
    map "models" => :model
    # rubocop:enable Style/StringHashKeys

    desc "model", "Sync Model, DB, Factory Files with API"
    def model
      cp_dir = %w[db app/models spec/factories]
      cp_dir.each do |dir|
        cp_and_dl_files(dir: dir)
      end
      puts(Paint % ["Synced! : %{white_text}", :green, { white_text: [cp_dir.to_s, :white] }])
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    private

    def cp_and_dl_files(dir: "db")
      require("#{Souls.get_mother_path}/config/souls")
      worker_paths = Souls.configuration.workers.map { |n| n[:name].split("-").last }
      worker_paths.each do |path|
        cp_path = "./apps/api/#{dir}"
        old_path = "./apps/#{path}/#{dir}"
        system("rm -rf #{old_path}", chdir: Souls.get_mother_path)
        system("mkdir -p #{old_path}", chdir: Souls.get_mother_path)
        system("cp -r #{cp_path}/* #{old_path}", chdir: Souls.get_mother_path)
      rescue StandardError
        # Do nothing
      end
    end
  end
end
