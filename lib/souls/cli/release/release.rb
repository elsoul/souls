module Souls
  class CLI < Thor
    desc "release", "Release Gem"
    def release
      raise(StandardError, "hey! It's Broken!") unless system("rspec")

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
          update_service_gemfile(service_name: s_name, version: souls_new_ver)
          result = Paint[update_repo(service_name: s_name, update_kind: update_kind), :green]
          Whirly.status = result
        end
        overwrite_version(new_version: souls_new_ver)
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

    private

    def update_repo(service_name: "api", update_kind: "patch")
      current_dir_name = FileUtils.pwd.to_s.match(%r{/([^/]+)/?$})[1]
      current_ver = Souls.get_latest_version_txt(service_name: service_name)
      new_ver = Souls.version_detector(current_ver: current_ver, update_kind: update_kind)
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
  end
end
