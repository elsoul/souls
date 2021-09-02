module Souls
  module Sync
    class << self
      def model
        cp_dir = %w[db app/models spec/factories]
        cp_dir.each do |dir|
          cp_and_dl_files(dir: dir)
        end
      end

      private

      def cp_and_dl_files(dir: "db")
        require("#{Souls.get_mother_path}/config/souls")
        worker_paths = Souls.configuration.workers
        worker_paths.each do |path|
          cp_path = "./apps/api/#{dir}"
          old_path = "./apps/#{path}/#{dir}"
          FileUtils.rm_rf(old_path) if Dir.exist?(old_path)
          FileUtils.mkdir(old_path) unless Dir.exist?(old_path)
          system("cp -r #{cp_path}/* #{old_path}", chdir: Souls.get_mother_path)
        end
      end
    end
  end
end
