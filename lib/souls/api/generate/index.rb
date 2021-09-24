require_paths = []
dev_path = "lib/souls/api/generate/*"
gem_path = "#{Gem.dir}/gems/souls-#{Souls::VERSION}/lib/souls/api/generate/*"
file_paths = File.exist?("souls.gemspec") ? dev_path : gem_path
Dir[file_paths].map do |n|
  next if n.include?("index.rb")

  require_paths << n.split("/").last.gsub(".rb", "")
end
require_paths.each do |path|
  require_relative "./#{path}"
end
