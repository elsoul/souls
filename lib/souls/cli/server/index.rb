module Souls
  class CLI < Thor
    desc "server", "Run SOULs APP"
    method_option all: :boolean, alias: "--all", default: false, desc: "Run All API & Workers"
    def server
      if options[:all]
        Dir.chdir(Souls.get_mother_path.to_s) do
          system("foreman start -f Procfile.dev")
        end
      else
        system("foreman start -f Procfile.dev")
      end
    end
  end
end
