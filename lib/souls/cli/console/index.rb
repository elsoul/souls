module Souls
  class CLI < Thor
    desc "console", "Run IRB Console"
    method_option :env, aliases: "--e", default: "development", desc: "Difine APP Enviroment - development | production"
    def console
      return system("RACK_ENV=production bundle exec irb") if options[:env].eql?("production")

      system("bundle exec irb")
    end
  end
end
