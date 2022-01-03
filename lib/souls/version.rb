require "fileutils"
module Souls
  VERSION = "1.15.5".freeze
  public_constant :VERSION

  SOULS_PATH =
    if FileUtils.pwd.split("/").last == "souls"
      ".".freeze
    else
      "#{Gem.dir}/gems/souls-#{Souls::VERSION}".freeze
    end
  public_constant :SOULS_PATH
end
