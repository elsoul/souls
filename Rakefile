require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "./lib/souls"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :task do
  task :g do
    file_path = "./lib/souls/generate/"
    Souls::SOULS_METHODS.each do |f|
      FileUtils.touch "#{file_path}#{f}.rb"
    end
  end

  task :a do
    file_path = "./spec/generate/"
    Souls::SOULS_METHODS.each do |f|
      FileUtils.touch "#{file_path}#{f}_spec.rb"
    end
  end
end
