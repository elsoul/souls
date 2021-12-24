require_relative "./template/functions_app"
require_relative "./template/functions_gemfile"
module Souls
  class Create < Thor
    desc "functions", "Create SOULs functions"
    def functions
      create_app_file
      create_gemfile
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

    def copy_souls_conf
      
    end
  end
end
