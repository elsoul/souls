require_relative "./template/functions_app"
require_relative "./template/functions_gemfile"
require_relative "./template/functions_env_yaml"
module Souls
  class Create < Thor
    desc "functions", "Create SOULs functions"
    def functions
      create_app_file
      create_gemfile
      create_env_yaml
    end

    private

    def create_app_file
      file_dir = "./apps/functions"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/app.rb"
      raise(StandardError, "Already Exist!") if File.exist?(file_path)

      File.write(file_path, Template.functions_app)
      Souls::Painter.create_file(file_path)
      file_path
    end

    def create_gemfile
      file_dir = "./apps/functions"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/Gemfile"
      raise(StandardError, "Already Exist!") if File.exist?(file_path)

      File.write(file_path, Template.functions_gemfile)
      Souls::Painter.create_file(file_path)
      file_path
    end

    def create_env_yaml
      file_dir = "./apps/functions"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/.env.yaml"
      raise(StandardError, "Already Exist!") if File.exist?(file_path)

      File.write(file_path, Template.functions_env_yaml)
      Souls::Painter.create_file(file_path)
      file_path
    end
  end
end
