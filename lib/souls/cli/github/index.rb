module Souls
  class Github < Thor
    desc "auth_login", "gcloud config set and gcloud auth login"
    def auth_login
      system("gh auth login")
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "secret_set", "Github Secret Set by Github CLI"
    def secret_set
      require("#{Souls.get_api_path}/config/souls")
      file_path = ".env.production"
      File.open(file_path, "r") do |file|
        file.each_line do |line|
          key_and_value = line.split("=")
          system("gh secret set #{key_and_value[0]} -b \"#{key_and_value[1]}\"")
        end
      end
    end
  end
end
