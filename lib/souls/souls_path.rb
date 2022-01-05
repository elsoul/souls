require "fileutils"
module SOULs
  SOULS_PATH =
    if FileUtils.pwd.split("/").last == "souls"
      ".".freeze
    else
      "#{Gem.dir}/gems/souls-#{SOULs::VERSION}".freeze
    end
  public_constant :SOULS_PATH
end
