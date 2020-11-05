require "souls"
require "yaml"
require "erb"
require "active_record"
require "logger"

$LOAD_PATH << "/Users/fumi/dev/souls/app/services"

Dir[File.expand_path "app/*.rb"].each do |file|
  require file
end

db_conf = YAML.safe_load(ERB.new(File.read("./config/database.yml")).result)
ActiveRecord::Base.establish_connection(db_conf)
Dir[File.expand_path "./app/controllers/*.rb"].sort.each do |file|
  require file
end
