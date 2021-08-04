require_relative "souls/version"
require "active_support/core_ext/string/inflections"
require_relative "souls/init"
require_relative "souls/generate"
require_relative "souls/gcloud"
require_relative "souls/release"
require "dotenv/load"
require "json"
require "fileutils"
require "net/http"
require "paint"
require "whirly"
require "tty-prompt"

module Souls
  SOULS_METHODS = %w[
    model
    query
    mutation
    type
    resolver
    policy
    rspec_factory
    rspec_model
    rspec_query
    rspec_mutation
    rspec_resolver
    rspec_policy
  ].freeze
  public_constant :SOULS_METHODS
  class Error < StandardError; end
  class << self
    attr_accessor :configuration

    def run_psql
      system(
        "docker run --rm -d \
          -p 5433:5432 \
          -v postgres-tmp:/var/lib/postgresql/data \
          -e POSTGRES_USER=postgres \
          -e POSTGRES_PASSWORD=postgres \
          -e POSTGRES_DB=souls_test \
          postgres:13-alpine"
      )
      system("docker ps")
    end

    def run_mysql
      system(
        "docker run --rm -d \
          -p 3306:3306 \
          -v mysql-tmp:/var/lib/mysql \
          -e MYSQL_USER=mysql \
          -e MYSQL_ROOT_PASSWORD=mysql \
          -e MYSQL_DB=souls_test \
          mysql:latest"
      )
      system("docker ps")
    end

    def run_awake(url)
      app = Souls.configuration.app
      system(
        "gcloud scheduler jobs create http #{app}-awake
        --schedule '0,10,20,30,40,50 * * * *' --uri #{url} --http-method GET"
      )
    end

    def gemfile_latest_version
      file_path = "./Gemfile"
      updated_gems = []
      updated_gem_versions = []
      updated_lines = []
      from_dev = false
      File.open(file_path, "r") do |f|
        f.each_line do |line|
          from_dev = true if line.include?("group")
          next unless line.include?("gem ")

          gem = line.gsub("gem ", "").gsub("\"", "").gsub("\n", "").gsub(" ", "").split(",")
          url = URI("https://rubygems.org/api/v1/versions/#{gem[0]}/latest.json")
          res = Net::HTTP.get_response(url)
          data = JSON.parse(res.body)
          next if Souls.configuration.fixed_gems.include?(gem[0].to_s)
          next if data["version"].to_s == gem[1].to_s

          updated_lines << if from_dev
                             "  gem \"#{gem[0]}\", \"#{data['version']}\""
                           else
                             "gem \"#{gem[0]}\", \"#{data['version']}\""
                           end
          updated_gems << (gem[0]).to_s
          updated_gem_versions << data["version"]
          system("gem update #{gem[0]}")
        end
      end
      {
        gems: updated_gems,
        lines: updated_lines,
        updated_gem_versions: updated_gem_versions
      }
    end

    def update_gemfile
      file_path = "./Gemfile"
      tmp_file = "./tmp/Gemfile"
      new_gems = gemfile_latest_version
      logs = []
      message = Paint["\nAlready Up to date!", :green]
      return "Already Up to date!" && puts(message) if new_gems[:gems].blank?

      @i = 0
      File.open(file_path, "r") do |f|
        File.open(tmp_file, "w") do |new_line|
          f.each_line do |line|
            gem = line.gsub("gem ", "").gsub("\"", "").gsub("\n", "").gsub(" ", "").split(",")
            if new_gems[:gems].include?(gem[0])
              old_ver = gem[1].split(".")
              new_ver = new_gems[:updated_gem_versions][@i].split(".")
              if old_ver[0] < new_ver[0]
                logs << Paint % [
                  "#{gem[0]} v#{gem[1]} → %{red_text}",
                  :white,
                  {
                    red_text: ["v#{new_gems[:updated_gem_versions][@i]}", :red]
                  }
                ]
              elsif old_ver[1] < new_ver[1]
                logs << Paint % [
                  "#{gem[0]} v#{gem[1]} → v#{new_ver[0]}.%{yellow_text}",
                  :white,
                  {
                    yellow_text: ["#{new_ver[1]}.#{new_ver[2]}", :yellow]
                  }
                ]
              elsif old_ver[2] < new_ver[2]
                logs << Paint % [
                  "#{gem[0]} v#{gem[1]} → v#{new_ver[0]}.#{new_ver[1]}.%{green_text}",
                  :white,
                  {
                    green_text: [(new_ver[2]).to_s, :green]
                  }
                ]
              end
              if gem[0] == "souls"
                logs << Paint % [
                  "\nSOULs Doc: %{cyan_text}",
                  :white,
                  { cyan_text: ["https://souls.elsoul.nl\n", :cyan] }
                ]
              end
              new_line.write("#{new_gems[:lines][@i]}\n")
              @i += 1
            else
              new_line.write(line)
            end
          end
        end
      end
      FileUtils.rm("./Gemfile")
      FileUtils.rm("./Gemfile.lock")
      FileUtils.mv("./tmp/Gemfile", "./Gemfile")
      system("bundle update")
      success = Paint["\n\nSuccessfully Updated These Gems!\n", :green]
      puts(success)
      logs.each do |line|
        puts(line)
      end
    end

    def update_repo(service_name: "api", update_kind: "patch")
      current_dir_name = FileUtils.pwd.to_s.match(%r{/([^/]+)/?$})[1]
      current_ver = get_latest_version_txt(service_name: service_name)
      new_ver = version_detector(current_ver: current_ver, update_kind: update_kind)
      bucket_url = "gs://souls-bucket/boilerplates"
      file_name = "#{service_name}-v#{new_ver}.tgz"
      release_name = "#{service_name}-latest.tgz"

      case current_dir_name
      when "souls"
        system("echo '#{new_ver}' > lib/souls/versions/.souls_#{service_name}_version")
        system("echo '#{new_ver}' > apps/#{service_name}/.souls_#{service_name}_version")
        system("cd apps/ && tar -czf ../#{service_name}.tgz #{service_name}/ && cd ..")
      when "api", "worker", "console", "admin", "media"
        system("echo '#{new_ver}' > lib/souls/versions/.souls_#{service_name}_version")
        system("echo '#{new_ver}' > .souls_#{service_name}_version")
        system("cd .. && tar -czf ../#{service_name}.tgz #{service_name}/ && cd #{service_name}")
      else
        raise(StandardError, "You are at wrong directory!")
      end

      system("gsutil cp #{service_name}.tgz #{bucket_url}/#{service_name.pluralize}/#{file_name}")
      system("gsutil cp #{service_name}.tgz #{bucket_url}/#{service_name.pluralize}/#{release_name}")
      FileUtils.rm("#{service_name}.tgz")
      "#{service_name}-v#{new_ver} Succefully Stored to GCS! "
    end

    def version_detector(current_ver: [0, 0, 1], update_kind: "patch")
      case update_kind
      when "patch"
        "#{current_ver[0]}.#{current_ver[1]}.#{current_ver[2] + 1}"
      when "minor"
        "#{current_ver[0]}.#{current_ver[1] + 1}.0"
      when "major"
        "#{current_ver[0] + 1}.0.0"
      else
        raise(StandardError, "Wrong version!")
      end
    end

    def overwrite_version(new_version: "0.1.1")
      FileUtils.rm("./lib/souls/version.rb")
      file_path = "./lib/souls/version.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Souls
            VERSION = "#{new_version}".freeze
            public_constant :VERSION
          end
        TEXT
      end
      overwrite_gemfile_lock(new_version: new_version)
      true
    rescue StandardError, e
      raise(StandardError, e)
    end

    def overwrite_gemfile_lock(new_version: "0.1.1")
      file_path = "Gemfile.lock"
      new_file_path = "Gemfile.lock.tmp"
      File.open(file_path, "r") do |f|
        File.open(new_file_path, "w") do |new_line|
          f.each_line.with_index do |line, i|
            if i == 3
              new_line.write("    souls (#{new_version})\n")
            else
              new_line.write(line)
            end
          end
        end
      end
      FileUtils.rm(file_path)
      FileUtils.mv(new_file_path, file_path)
    end

    def get_latest_version_txt(service_name: "api")
      case service_name
      when "gem"
        return Souls::VERSION.split(".").map(&:to_i)
      when "api", "worker", "console", "admin", "media"
        file_path = "#{Gem.dir}/gems/souls-#{Souls::VERSION}/lib/souls/versions/.souls_#{service_name}_version"
      else
        raise(StandardError, "You are at wrong directory!")
      end
      File.open(file_path, "r") do |f|
        f.readlines[0].strip.split(".").map(&:to_i)
      end
    end

    def update_service_gemfile(service_name: "api", version: "0.0.1")
      file_dir = "./apps/#{service_name}"
      file_path = "#{file_dir}/Gemfile"
      gemfile_lock = "#{file_dir}/Gemfile.lock"
      tmp_file = "#{file_dir}/tmp/Gemfile"
      File.open(file_path, "r") do |f|
        File.open(tmp_file, "w") do |new_line|
          f.each_line do |line|
            gem = line.gsub("gem ", "").gsub("\"", "").gsub("\n", "").gsub(" ", "").split(",")
            if gem[0] == "souls"
              old_ver = gem[1].split(".")
              old_ver[2] = (old_ver[2].to_i + 1).to_s
              new_line.write("  gem \"souls\", \"#{version}\"\n")
            else
              new_line.write(line)
            end
          end
        end
      end
      FileUtils.rm(file_path)
      FileUtils.rm(gemfile_lock) if File.exist?(gemfile_lock)
      FileUtils.mv(tmp_file, file_path)
      puts(Paint["\nSuccessfully Updated #{service_name} Gemfile!", :green])
    end

    def update_models(api_dir: "../api/db", worker_dir: "./db", push: false)
      current_dir_name = FileUtils.pwd.to_s.match(%r{/([^/]+)/?$})[1]
      wrong_dir = %w[apps api]
      raise(StandardError, "You are at wrong directory!Go to Worker Directory!") if wrong_dir.include?(current_dir_name)

      api_file_data = file_diff(Dir["#{api_dir}/*.rb"])
      worker_file_data = file_diff(Dir["#{worker_dir}/*.rb"])

      error_text =
        "detected some changes in you #{worker_dir} dir.Please check both #{api_dir} and #{worker_dir} before update."

      if push == true
        raise(StandardError, error_text) if api_file_data.max > worker_file_data.max

        FileUtils.rm_rf(api_dir)
        FileUtils.mkdir(api_dir) unless Dir.exist?(api_dir)
        system("cp -r #{worker_dir}/* #{api_dir}")
      else
        raise(StandardError, error_text) if api_file_data.max < worker_file_data.max

        FileUtils.rm_rf(worker_dir)
        FileUtils.mkdir(worker_dir) unless Dir.exist?(worker_dir)
        system("cp -r #{api_dir}/* #{worker_dir}")
      end
    end

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

    def detect_change
      git_status = `git status`
      result =
        %w[api worker].map do |service_name|
          next unless git_status.include?("apps/#{service_name}/")

          service_name
        end
      result.compact
    end

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end

  class Configuration
    attr_accessor :app, :strain, :project_id, :worker_repo, :api_repo, :worker_endpoint, :fixed_gems

    def initialize
      @app = nil
      @project_id = nil
      @strain = nil
      @worker_repo = nil
      @api_repo = nil
      @worker_endpoint = nil
      @fixed_gems = nil
    end
  end
end
