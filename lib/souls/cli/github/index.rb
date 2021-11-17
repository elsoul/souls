module Souls
  class Github < Thor
    desc "secret_set", "Github Secret Set from .env.production"
    def secret_set
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_path = ".env.production"
        File.open(file_path, "r") do |file|
          file.each_line do |line|
            key_and_value = line.split("=")
            system("gh secret set #{key_and_value[0]} -b \"#{key_and_value[1].strip}\"")
          end
        end
      end
    end

    desc "add_env", "Add New env and Sync Github Secret"
    method_option :dqm, type: :boolean, aliases: "--dqm", default: false, desc: "Enable Double Quotation Mark"
    def add_env
      prompt = TTY::Prompt.new
      key = prompt.ask("Set Key:")
      value = prompt.ask("Set Value:")
      update_env_production(key: key, value: value, dqm: options[:dqm])
      update_api_env(key: key, value: value, dqm: options[:dqm])
      update_workers_env(key: key, value: value, dqm: options[:dqm])
      update_github_actions(key: key)
      Souls::Github.new.invoke(:secret_set)
    end

    desc "watch", "Watch GitHub Actions Workflow"
    def watch
      run_id = `gh run list | grep Mailer | awk '{print $7}'`.strip
      raise(StandardError, "No workflow is running.") if run_id.include?("push")

      system("gh run watch #{run_id}")
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

    def update_workers_env(key:, value:, dqm: false)
      Dir.chdir(Souls.get_mother_path.to_s) do
        workers = Dir["apps/*"]
        workers.delete("apps/api")
        workers.each do |worker_path|
          file_path = "#{worker_path}/.env"
          File.open(file_path, "a") do |line|
            dqm ? line.write("\n#{key.upcase}=\"#{value}\"") : line.write("\n#{key.upcase}=#{value}")
          end
          puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
        end
      end
    end

    def update_github_actions(key:)
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_paths = Dir[".github/workflows/*.yml"]
        file_paths.each do |file_path|
          worker_workflow = File.readlines(file_path)
          worker_workflow[worker_workflow.size - 1] = worker_workflow.last.chomp
          worker_workflow << " \\ \n            --set-env-vars=\"#{key.upcase}=${{ secrets.#{key.upcase} }}\""
          File.open(file_path, "w") { |f| f.write(worker_workflow.join) }
          puts(Paint % ["Updated file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
        end
      end
    end
  end
end
