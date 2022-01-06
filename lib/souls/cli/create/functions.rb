require_relative "./templates/functions_env_yaml"

Dir["#{SOULs::SOULS_PATH}/lib/souls/cli/create/templates/*/*.rb"].map do |f|
  require f
end

module SOULs
  class Create < Thor
    desc "functions [name]", "Create SOULs functions"
    def functions(function_name)
      supported_languages = {
        ruby: %w[2.6 2.7],
        nodejs: %w[16 14 12 10],
        python: %w[3.9 3.8 3.7],
        go: ["1.16", "1.13"]
      }

      prompt = TTY::Prompt.new
      runtime = prompt.select("Select Runtime?", supported_languages.keys.map(&:to_s).map(&:camelize))
      runtime_downcased = runtime.downcase
      version = prompt.select("Select Version?", supported_languages[runtime.downcase.to_sym].sort.reverse)
      version_string = "#{runtime_downcased}#{version.gsub('.', '')}"
      runtime_methods = get_runtime_create_method(runtime: runtime_downcased)
      file_dir = "./apps/cf-#{version_string}-#{function_name}"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)

      runtime_methods.each do |method|
        file_extension =
          case runtime_downcased
          when "nodejs"
            method == "package" ? "json" : "js"
          when "python"
            method == "requirements" ? "txt" : "py"
          when "go"
            method == "go" ? "mod" : "go"
          else
            "rb"
          end
        file_path =
          if method == "gemfile"
            "#{file_dir}/Gemfile"
          else
            "#{file_dir}/#{method}.#{file_extension}"
          end
        file_name = file_dir.gsub("./apps/", "")
        File.write(file_path, Object.const_get("Template::#{runtime}").__send__(method, file_name))
        SOULs::Painter.create_file(file_path)
      end
      create_env_yaml(file_dir: file_dir)
    end

    private

    def create_env_yaml(file_dir:)
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/.env.yaml"
      raise(StandardError, "Already Exist!") if File.exist?(file_path)

      File.write(file_path, Template.functions_env_yaml)
      SOULs::Painter.create_file(file_path)
      file_path
    end

    def get_runtime_create_method(runtime:)
      Dir["#{SOULs::SOULS_PATH}/lib/souls/cli/create/templates/#{runtime}/*"].map do |n|
        n.split("/").last.gsub(".rb", "")
      end
    end
  end
end
