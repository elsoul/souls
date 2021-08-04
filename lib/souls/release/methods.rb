module Souls
  module Release
    class << self
      def return_method
        system("gem install souls")
        sleep(3)
        current_souls_ver = Souls::VERSION.strip.split(".").map(&:to_i)
        prompt = TTY::Prompt.new
        choices = [
          "1. Patch(#{Souls.version_detector(current_ver: current_souls_ver, update_kind: 'patch')})",
          "2. Minor(#{Souls.version_detector(current_ver: current_souls_ver, update_kind: 'minor')})",
          "3. Major(#{Souls.version_detector(current_ver: current_souls_ver, update_kind: 'major')})"
        ]
        choice_num = prompt.select("Select Version: ", choices)[0].to_i
        update_kinds = %w[patch minor major]
        update_kind = update_kinds[choice_num - 1]
        souls_new_ver = Souls.version_detector(current_ver: current_souls_ver, update_kind: update_kind)
        status = Paint["Saving Repo...", :yellow]
        Whirly.start(spinner: "clock", interval: 420, stop: "🎉") do
          Whirly.status = status
          %w[api worker].each do |s_name|
            Souls.update_service_gemfile(service_name: s_name, version: souls_new_ver)
            result = Paint[Souls.update_repo(service_name: s_name, update_kind: update_kind), :green]
            Whirly.status = result
          end
          Souls.overwrite_version(new_version: souls_new_ver)
          puts("before add")
          system("git add .")
          puts("before commit")
          system("git commit -m 'souls update v#{souls_new_ver}'")
          puts("before build")
          system("rake build")
          system("rake release")
          Whirly.status = Paint["soul-v#{souls_new_ver} successfully updated!"]
        end
      end
    end
  end
end
