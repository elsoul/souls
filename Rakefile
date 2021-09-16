require "bundler/gem_tasks"
require "rspec/core/rake_task"
# require "./lib/souls"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :upload do
  task :github do
    file_name = "./github.tgz"
    system("tar -czf #{file_name} github/")
    system("gsutil cp #{file_name} gs://souls-bucket/github_actions/")
    FileUtils.rm(file_name.to_s)
  end
end

namespace :task do
  task :g do
    file_path = "./lib/souls/generate/"
    Souls::SOULS_METHODS.each do |f|
      FileUtils.touch("#{file_path}#{f}.rb")
    end
  end

  task :clear do
    file_paths = [
      "./app",
      "./spec/factories",
      "./spec/models",
      "./spec/mutations",
      "./spec/queries",
      "./spec/resolvers",
      "./spec/policies"
    ]
    file_paths.each { |path| FileUtils.rm_rf(path) if Dir.exist?(path) }
  end
end
