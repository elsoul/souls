require_paths = []
dev_path = "lib/souls/cli/generate/*"
souls_path = Dir["#{Gem.dir}/gems/souls-*"].last
gem_path = "#{souls_path}/lib/souls/cli/generate/*"
file_paths = File.exist?("souls.gemspec") ? dev_path : gem_path
Dir[file_paths].map do |n|
  next if n.include?("index.rb")

  require_paths << n.split("/").last.gsub(".rb", "")
end
require_paths.each do |path|
  require_relative "./#{path}"
end

module Souls
  class Generate < Thor
  end
end
