require "./lib/souls"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :task do
  task :g do
    file_path = "./lib/souls/generate/"
    Souls::SOULS_METHODS.each do |f|
      FileUtils.touch "#{file_path}#{f}.rb"
    end
  end
end
