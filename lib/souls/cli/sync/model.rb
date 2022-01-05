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
        cp_env_files
      end
      Souls::Painter.sync(cp_dir.to_s)
    end

    private

    def cp_and_dl_files(dir: "db")
      require("#{Souls.get_mother_path}/config/souls")
      project_id = Souls.configuration.project_id
      worker_paths = Souls.configuration.workers.map { |n| n[:name].split("souls-#{project_id}-").last }
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

    def cp_env_files
      return unless File.exist?("#{Souls.get_mother_path}/apps/api/.env")

      project_id = Souls.configuration.project_id
      worker_paths = Souls.configuration.workers.map { |n| n[:name].split("souls-#{project_id}-").last }
      worker_paths.each do |path|
        system("rm -f ./apps/#{path}/.env", chdir: Souls.get_mother_path)
        system("cp -f ./apps/api/.env ./apps/#{path}/.env", chdir: Souls.get_mother_path)
      end
    end
  end
end
