module Souls
  class Upgrade < Thor
    desc "gemfile", "Update Gemfile/Gemfile.lock Version"
    def gemfile
      status = Paint["Checking Latest Gems...", :yellow]
      Whirly.start(spinner: "clock", interval: 420, stop: "🎉") do
        Whirly.status = status
        update_gem
        Whirly.status = "Done!"
      end
    end

    private

    def update_gem
      file_path = "./Gemfile"
      tmp_file = "./tmp/Gemfile"
      new_gems = gemfile_latest_version
      logs = []
      message = Paint["\nAlready Up to date!", :green]
      return "Already Up to date!" && puts(message) if new_gems[:gems].blank?

      @i = 0
      File.open(file_path, "r") do |f|
        File.open(tmp_file, "w") do |new_line|
          f.each_line do |line|
            gem = line.gsub("gem ", "").gsub("\"", "").gsub("\n", "").gsub(" ", "").split(",")
            if new_gems[:gems].include?(gem[0])
              old_ver = gem[1].split(".")
              new_ver = new_gems[:updated_gem_versions][@i].split(".")
              if old_ver[0] < new_ver[0]
                logs << (Paint % [
                  "#{gem[0]} v#{gem[1]} → %{red_text}",
                  :white,
                  {
                    red_text: ["v#{new_gems[:updated_gem_versions][@i]}", :red]
                  }
                ])
              elsif old_ver[1] < new_ver[1]
                logs << (Paint % [
                  "#{gem[0]} v#{gem[1]} → v#{new_ver[0]}.%{yellow_text}",
                  :white,
                  {
                    yellow_text: ["#{new_ver[1]}.#{new_ver[2]}", :yellow]
                  }
                ])
              elsif old_ver[2] < new_ver[2]
                logs << (Paint % [
                  "#{gem[0]} v#{gem[1]} → v#{new_ver[0]}.#{new_ver[1]}.%{green_text}",
                  :white,
                  {
                    green_text: [(new_ver[2]).to_s, :green]
                  }
                ])
              end
              if gem[0] == "souls"
                logs << (Paint % [
                  "\nSOULs Doc: %{cyan_text}",
                  :white,
                  { cyan_text: ["https://souls.elsoul.nl\n", :cyan] }
                ])
              end
              new_line.write("#{new_gems[:lines][@i]}\n")
              @i += 1
            else
              new_line.write(line)
            end
          end
        end
      end
      FileUtils.rm("./Gemfile")
      FileUtils.rm("./Gemfile.lock")
      FileUtils.mv("./tmp/Gemfile", "./Gemfile")
      system("bundle update")
      success = Paint["\n\nSuccessfully Updated These Gems!\n", :green]
      puts(success)
      logs.each do |line|
        puts(line)
      end
    end

    def gemfile_latest_version
      file_path = "./Gemfile"
      updated_gems = []
      updated_gem_versions = []
      updated_lines = []
      from_dev = false
      File.open(file_path, "r") do |f|
        f.each_line do |line|
          from_dev = true if line.include?("group")
          next unless line.include?("gem ")

          gem = line.gsub("gem ", "").gsub("\"", "").gsub("\n", "").gsub(" ", "").split(",")
          url = URI("https://rubygems.org/api/v1/versions/#{gem[0]}/latest.json")
          res = Net::HTTP.get_response(url)
          data = JSON.parse(res.body)
          next if Souls.configuration.fixed_gems.include?(gem[0].to_s)
          next if data["version"].to_s == gem[1].to_s

          updated_lines << if from_dev
                             "  gem \"#{gem[0]}\", \"#{data['version']}\""
                           else
                             "gem \"#{gem[0]}\", \"#{data['version']}\""
                           end
          updated_gems << (gem[0]).to_s
          updated_gem_versions << data["version"]
          system("gem update #{gem[0]}")
        end
      end
      {
        gems: updated_gems,
        lines: updated_lines,
        updated_gem_versions: updated_gem_versions
      }
    end
  end
end
