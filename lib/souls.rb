require_relative "souls/version"
require "active_support/core_ext/string/inflections"
require_relative "souls/init"
require_relative "souls/generate"
require_relative "souls/gcloud"
require "json"
require "fileutils"
require "net/http"
require "paint"
require "whirly"

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
  end

  def self.run_psql
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

  def self.run_mysql
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

  def self.run_awake(url)
    app = Souls.configuration.app
    system(
      "gcloud scheduler jobs create http #{app}-awake
      --schedule '0,10,20,30,40,50 * * * *' --uri #{url} --http-method GET"
    )
  end

  def self.show_wait_spinner(fps = 10)
    chars = %w[| / - \\]
    delay = 1.0 / fps
    iter = 0
    spinner =
      Thread.new do
        while iter
          print(chars[(iter += 1) % chars.length])
          sleep(delay)
          print("\b")
        end
      end
    yield.tap do
      iter = false
      spinner.join
    end
  end

  def self.gemfile_latest_version
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

  def self.update_gemfile
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
              logs << Paint % ["\nSOULs Doc: %{cyan_text}", :white, { cyan_text: ["https://souls.elsoul.nl\n", :cyan] }]
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

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :app, :strain, :project_id, :worker_name, :api_name

    def initialize
      @app = nil
      @project_id = nil
      @strain = nil
      @worker_name = nil
      @api_name = nil
    end
  end
end
