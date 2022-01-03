require "fileutils"
module Souls
  SOULS_PATH =
    if FileUtils.pwd.split("/").last == "souls"
      ".".freeze
    else
      "#{Gem.dir}/gems/souls-#{Souls::VERSION}".freeze
    end
  public_constant :SOULS_PATH
end
