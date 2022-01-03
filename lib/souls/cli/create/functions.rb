require_relative "./template/functions_env_yaml"

runtimes =
  Dir["#{Souls::SOULS_PATH}/lib/souls/cli/create/template/*"].map do |f|
    f.split("/").last unless f.split("/").last.include?(".rb")
  end
runtimes.compact!
runtimes.each { |f| require_relative "./template/#{f}/index" }

module Souls
  class Create < Thor
    desc "functions", "Create SOULs functions"
    def functions(_function_name)
      runtimes =
        Dir["#{Souls::SOULS_PATH}/lib/souls/cli/create/template/*"].map do |f|
          f.split("/").last unless f.split("/").last.include?(".rb")
        end
      runtimes.compact!
      prompt = TTY::Prompt.new
      runtime = prompt.select("Select Runtime?", runtimes.reverse)
      runtime_camelized = runtime.camelize
      version = prompt.select("Select Version?", get_runtime_versions(runtime: runtime).reverse)
      version_camelized = version.camelize

      runtime_methods = get_runtime_create_method(runtime: runtime, version: version)

      file_dir = "./apps/cf_#{version}_#{name}"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)

      runtime_methods.each do |method|
        file_path = "#{file_dir}/#{method}.rb"
        File.write(file_path, Object.const_get("Template::#{runtime_camelized}::#{version_camelized}").__send__(method))
        Souls::Painter.create_file(file_path)
      end
      create_env_yaml(file_dir: file_dir)
    end

    private

    def create_env_yaml(file_dir:)
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/.env.yaml"
      raise(StandardError, "Already Exist!") if File.exist?(file_path)

      File.write(file_path, Template.functions_env_yaml)
      Souls::Painter.create_file(file_path)
      file_path
    end

    def get_runtime_versions(runtime:)
      files =
        Dir["lib/souls/cli/create/template/#{runtime}/*"].map do |n|
          next if n.split("/").last == "index.rb"

          n.split("/").last
        end
      files.compact!
    end

    def get_runtime_create_method(runtime:, version:)
      files =
        Dir["lib/souls/cli/create/template/#{runtime}/#{version}/*"].map do |n|
          next if n.split("/").last == "index.rb"

          n.split("/").last.gsub(".rb", "")
        end
      files.compact!
    end
  end
end
