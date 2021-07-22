require_relative "souls/version"
require "active_support/core_ext/string/inflections"
require_relative "souls/init"
require_relative "souls/generate"
require_relative "souls/gcloud"
require "dotenv/load"
require "json"
require "fileutils"
require "net/http"
require "paint"
require "whirly"
require "google/cloud/firestore"

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

    def update_repo(service_name: "api")
      current_dir_name = FileUtils.pwd.to_s.match(%r{/([^/]+)/?$})[1]
      latest_gem = get_latest_version(service_name: service_name)
      new_ver = latest_gem[:version_counter] + 1
      bucket_url = "gs://souls-bucket/boilerplates"
      file_name = "#{service_name}-v#{new_ver}.tgz"
      release_name = "#{service_name}-latest.tgz"

      case current_dir_name
      when "souls"
        system("echo 'v#{new_ver}' > apps/#{service_name}/.souls_version")
        system("cd apps/ && tar -czf ../#{service_name}.tgz #{service_name}/ && cd ..")
      when "api", "worker", "console", "admin", "media"
        system("echo 'v#{new_ver}' > .souls_version")
        system("cd .. && tar -czf ../#{service_name}.tgz #{service_name}/ && cd #{service_name}")
      else
        raise(StandardError, "You are at wrong directory!")
      end

      system("gsutil cp #{service_name}.tgz #{bucket_url}/#{service_name.pluralize}/#{file_name}")
      system("gsutil cp #{service_name}.tgz #{bucket_url}/#{service_name.pluralize}/#{release_name}")
      file_url = "https://storage.googleapis.com/souls-bucket/boilerplates/#{service_name.pluralize}/#{file_name}"
      version_log(service_name: service_name, version_counter: new_ver, file_url: file_url)
      FileUtils.rm("#{service_name}.tgz")
      "#{service_name}-v#{new_ver} Succefully Stored to GCS! "
    end

    def version_log(service_name: "api", version_counter: 1, file_url: "")
      version = "v#{version_counter}"
      time = Time.now.strftime("%F-%H-%M-%S")
      firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PID"])
      doc_ref = firestore.doc("#{service_name}/#{version_counter}")
      doc_ref.set({ version: version, version_counter: version_counter, file_url: file_url, created_at: time })
    end

    def get_latest_version(service_name: "api")
      firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PID"])
      versions = firestore.doc("#{service_name}/1")
      if versions.get.exists?
        versions = firestore.col(service_name.to_s)
        query = versions.order("version_counter", "desc").limit(1)
        query.get do |v|
          return {
            version_counter: v.data[:version_counter],
            version: v.data[:version],
            file_url: v.data[:file_url],
            create_at: v.data[:create_at]
          }
        end
      else
        { version_counter: 0 }
      end
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
