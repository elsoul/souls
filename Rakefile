require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "sinatra/activerecord"
require "sinatra/activerecord/rake"
require_relative "./lib/souls"
require "./config/souls"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :upload do
  @gs_bucket_url = "gs://souls-bucket/boilerplates/#{SOULs::VERSION}"
  task :github do
    file_name = "./github.tgz"
    system("tar -czf #{file_name} github/")
    system("gsutil cp #{file_name} #{@gs_bucket_url}/github_actions/")
    system("rm -rf #{file_name}")
  end

  task :init_files do
    system("gcloud config set project elsoul-nl")
    Rake::Task["upload:github"].invoke
    files = Dir.glob("init_files/*", File::FNM_DOTMATCH)
    2.times { files.shift }
    files.each do |file|
      system("gsutil cp #{file} #{@gs_bucket_url}/")
    end
  end
end
