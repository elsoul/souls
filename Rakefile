require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "sinatra/activerecord"
require "sinatra/activerecord/rake"
require_relative "./lib/souls"
require "./config/souls"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :upload do
  task :github do
    file_name = "./github.tgz"
    system("tar -czf #{file_name} github/")
    system("gsutil cp #{file_name} gs://souls-bucket/boilerplates/github_actions/")
    system("rm -rf #{file_name}")
  end

  task :sig do
    file_name = "./sig.tgz"
    system("tar -czf #{file_name} sig/")
    system("gsutil cp #{file_name} gs://souls-bucket/boilerplates/sig/")
    system("rm -rf #{file_name}")
  end

  task :init_files do
    Rake::Task["upload:github"].invoke
    Rake::Task["upload:sig"].invoke
    files = Dir["init_files/*"]
    files << ".rubocop.yml"
    files.each do |file|
      system("gsutil cp #{file} gs://souls-bucket/boilerplates/")
    end
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
