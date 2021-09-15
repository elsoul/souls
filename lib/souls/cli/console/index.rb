module Souls
  class CLI < Thor
    desc "c", "Run IRB Console"
    method_option :env, aliases: "--e", default: "development", desc: "Difine APP Enviroment - development | production"
    def c
      case options[:env]
      when "production"
        system("RACK_ENV=production bundle exec irb")
      else
        system("bundle exec irb")
      end
    end
  end
end