module Souls
  module Sync
    class << self
      def model
        current_dir_name = FileUtils.pwd.to_s.match(%r{/([^/]+)/?$})[1]
        permitted_dirs = %w[worker api]
        unless permitted_dirs.include?(current_dir_name)
          raise(StandardError, "You are at wrong directory!Go to API or Worker Directory!")
        end

        cp_dir = get_models_path(service_name: current_dir_name)
        cp_dir.each do |path|
          cp_and_dl_files(api_dir: path[:api], worker_dir: path[:worker])
        end
      end

      private

      def file_diff(paths = [])
        paths.map do |path|
          stat(path)[:last_update]
        end
      end

      def stat(path)
        s = File::Stat.new(path)
        last_update = s.mtime.to_s
        last_status_change = s.ctime.to_s
        last_access = s.atime.to_s
        {
          last_update: last_update,
          last_status_change: last_status_change,
          last_access: last_access
        }
      end

      def cp_and_dl_files(api_dir: "", worker_dir: "")
        if Dir["#{worker_dir}/*.rb"].blank?

          api_latest_date = 1
          worker_latest_date = 0
        else
          api_file_data = file_diff(Dir["#{api_dir}/*.rb"])
          worker_file_data = file_diff(Dir["#{worker_dir}/*.rb"])

          api_latest_date = Date.parse(api_file_data.max)
          worker_latest_date = Date.parse(worker_file_data.max)
        end

        if api_latest_date < worker_latest_date
          FileUtils.rm_rf(api_dir) if Dir.exist?(api_dir)
          FileUtils.mkdir_p(api_dir) unless Dir.exist?(api_dir)
          system("cp -r #{worker_dir}/* #{api_dir}")
        else
          FileUtils.rm_rf(worker_dir) if Dir.exist?(worker_dir)
          FileUtils.mkdir_p(worker_dir) unless Dir.exist?(worker_dir)
          system("cp -r #{api_dir}/* #{worker_dir}")
        end
      rescue StandardError => e
        puts(e.backtrace)
      end

      def get_models_path(service_name: "api")
        case service_name
        when "api"
          api_path = "."
          worker_path = "../worker"
        when "worker"
          api_path = "../api"
          worker_path = "."
        end
        [
          {
            api: "#{api_path}/db",
            worker: "#{worker_path}/db"
          },
          {
            api: "#{api_path}/app/models",
            worker: "#{worker_path}/app/models"
          },
          {
            api: "#{api_path}/spec/factories",
            worker: "#{worker_path}/spec/factories"
          }
        ]
      end
    end
  end
end
