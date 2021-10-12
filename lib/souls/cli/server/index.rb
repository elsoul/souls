module Souls
  class CLI < Thor
    desc "server", "Run SOULs APP"
    method_option :all, type: :boolean, alias: "--all", default: false, desc: "Run All API & Workers"
    def server
      if options[:all]
        Dir.chdir(Souls.get_mother_path.to_s) do
          system("foreman start -f Procfile.dev")
        end
      else
        current_dir = FileUtils.pwd.split("/").last
        system("foreman start -f Procfile.dev")
        puts("GraphQL Playground is running on\n\nhttp://localhost:4000/playground") if current_dir == "api"
      end
    end
  end
end
