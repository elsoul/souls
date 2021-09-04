module Souls
  module Utils
    def get_mother_path
      FileUtils.pwd.split(Souls.configuration.app)[0] + Souls.configuration.app
    end

    def get_api_path
      FileUtils.pwd.split(Souls.configuration.app)[0] + Souls.configuration.app + "/apps/api"
    end
  end
end
