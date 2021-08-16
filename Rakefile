require "bundler/gem_tasks"
require "erb"
require "rspec/core/rake_task"
require "./lib/souls"

RSpec::Core::RakeTask.new(:spec)


task :default => :spec

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
