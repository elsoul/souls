module SOULs
  class CLI < Thor
    desc "server", "Run SOULs APP"
    method_option :all, type: :boolean, alias: "--all", default: false, desc: "Run All API & Workers"
    def server
      if options[:all]
        Dir.chdir(SOULs.get_mother_path.to_s) do
          front_path = "apps/console/package.json"
          system("foreman start -f Procfile.dev")
          system("cd apps/console && yarn dev") if File.exist?(front_path)
        end
      else
        package_json_path = "package.json"
        if File.exist?(package_json_path)
          system("yarn dev")
        else
          system("foreman start -f Procfile.dev")
        end
      end
    end
  end
end
