require "bundler/gem_tasks"
require "erb"
require "sinatra/activerecord/rake"
require "rspec/core/rake_task"
require "./lib/souls"

RSpec::Core::RakeTask.new(:spec)
ENV["RACK_ENV"] ||= "development"
db_conf = YAML.safe_load(ERB.new(File.read("./config/database.yml")).result, permitted_classes: [Date], aliases: true)
ActiveRecord::Base.establish_connection(db_conf[ENV["RACK_ENV"]])
ActiveRecord::Base.default_timezone = :local

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
