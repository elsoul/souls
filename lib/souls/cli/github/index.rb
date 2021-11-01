module Souls
  class Github < Thor
    desc "secret_set", "Github Secret Set from .env.production"
    def secret_set
      file_path = ".env.production"
      File.open(file_path, "r") do |file|
        file.each_line do |line|
          key_and_value = line.split("=")
          system("gh secret set #{key_and_value[0]} -b \"#{key_and_value[1].strip}\"")
        end
      end
    end

    desc "add_env", "Add New env and Sync Github Secret"
    method_option :key, aliases: "--key", required: true, desc: "Key Name"
    method_option :value, aliases: "--value", required: true, desc: "Value Name"
    method_option :dqm, type: :boolean, aliases: "--dqm", default: false, desc: "Enable Double Quotation Mark"
    def add_env
      update_env_production(key: options[:key], value: options[:value], dqm: options[:dqm])
      update_api_env(key: options[:key], value: options[:value], dqm: options[:dqm])
      update_github_actions(key: options[:key])
      Souls::Github.new.invoke(:secret_set)
    end

    private

    def update_env_production(key:, value:, dqm: false)
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_path = ".env.production"
        File.open(file_path, "a") do |line|
          dqm ? line.write("\n#{key.upcase}=\"#{value}\"") : line.write("\n#{key.upcase}=#{value}")
        end
        puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      end
    end

    def update_api_env(key:, value:, dqm: false)
      Dir.chdir(Souls.get_api_path.to_s) do
        file_path = ".env"
        File.open(file_path, "a") do |line|
          dqm ? line.write("\n#{key.upcase}=\"#{value}\"") : line.write("\n#{key.upcase}=#{value}")
        end
        puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      end
    end

    def update_github_actions(key:)
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_paths = Dir[".github/workflows/*.yml"]
        file_paths.each do |file_path|
          File.open(file_path, "a") do |line|
            line.write(" \\ \n            --set-env-vars=\"#{key.upcase}=${{ secrets.#{key.upcase} }}\"")
          end
          puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
        end
      end
    end
  end
end
