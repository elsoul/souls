require "active_support/core_ext/string/inflections"

require_paths = []
modules =
  Dir["lib/souls/cli/*"].map do |n|
    next if n.include?("index.rb")

    require_paths << n.split("/").last
    n.split("/").last.camelize
  end
modules.compact!
require_paths.each_with_index do |path, i|
  require_relative "./#{path}/index"
  Object.const_get("Souls::#{modules[i]}")
end
