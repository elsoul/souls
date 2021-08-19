require_relative "souls/index"
require "active_support/core_ext/string/inflections"
require "date"
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
      system("gsutil cp .rubocop.yml #{bucket_url}/.rubocop.yml")
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

    def check_schema(class_name: "user")
      schema_data = get_columns_num(class_name: class_name)
      create_migration_data = get_create_migration_type(class_name: class_name)
      add_migration_data = get_migration_type(class_name: class_name, action: "add")
      remove_migration_data = get_migration_type(class_name: class_name, action: "remove")
      migration_data = create_migration_data + add_migration_data - remove_migration_data
      return "Already Up to date!" if schema_data.size == migration_data.size

      schema_data - migration_data
    end

    def get_columns_num(class_name: "user")
      file_path = "./db/schema.rb"
      class_check_flag = false
      cols = []
      File.open(file_path, "r") do |f|
        f.each_line.with_index do |line, _i|
          class_check_flag = true if line.include?("create_table") && line.include?(class_name)
          if class_check_flag == true && !line.include?("create_table")
            return cols if line.include?("t.index") || line.strip == "end"

            types = Souls::Api::Generate.get_type_and_name(line)
            array = line.include?("array: true")
            cols << { column_name: types[1], type: types[0], array: array }
          end
        end
      end
      cols
    end

    def get_create_migration_type(class_name: "user")
      pluralized_class_name = class_name.pluralize
      file_path = Dir["db/migrate/*_create_#{pluralized_class_name}.rb"][0]

      class_check_flag = false
      response = [
        { column_name: "created_at", type: "datetime", array: false },
        { column_name: "updated_at", type: "datetime", array: false }
      ]
      File.open(file_path) do |f|
        f.each_line do |line|
          class_check_flag = true if line.include?("create_table")
          next unless class_check_flag == true && !line.include?("create_table")
          return response if line.include?("t.timestamps") || line.strip == "end"

          types = Souls::Api::Generate.get_type_and_name(line)
          types.map { |n| n.gsub!(":", "") }
          array = line.include?("array: true")
          response << { column_name: types[1], type: types[0], array: array }
        end
      end
    end

    def get_migration_type(class_name: "user", action: "add")
      pluralized_class_name = class_name.pluralize
      file_paths = Dir["db/migrate/*_#{action}_column_to_#{pluralized_class_name}.rb"]

      new_columns =
        file_paths.map do |file_path|
          get_col_name_and_type(class_name: class_name, file_path: file_path, action: action)
        end
      new_columns.flatten
    end

    def get_last_migration_type(class_name: "user", action: "add")
      pluralized_class_name = class_name.pluralize
      file_paths = Dir["db/migrate/*_#{action}_column_to_#{pluralized_class_name}.rb"]

      file_paths.max
      resoponse = get_col_name_and_type(class_name: class_name, file_path: file_paths.max, action: action)
      resoponse.flatten
    end

    def get_col_name_and_type(
      class_name: "user", file_path: "db/migrate/20210816094410_add_column_to_users.rb", action: "add"
    )
      pluralized_class_name = class_name.pluralize
      response = []
      File.open(file_path) do |line|
        line.each_line do |file_line|
          next unless file_line.include?("#{action}_column")

          array = file_line.include?("array: true")
          types = file_line.split(",").map(&:strip)
          types.map { |n| n.gsub!(":", "") }
          types[0].gsub!("#{action}_column ", "")
          unless types[0].to_s == pluralized_class_name
            raise(StandardError, "Wrong class_name!Please Check your migration file!")
          end

          response << { column_name: types[1], type: types[2], array: array }
        end
      end
      response
    end

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end

  class Configuration
    attr_accessor :app, :strain, :project_id, :github_repo, :worker_endpoint, :fixed_gems

    def initialize
      @app = nil
      @project_id = nil
      @strain = nil
      @github_repo = nil
      @worker_endpoint = nil
      @fixed_gems = nil
    end
  end
end
