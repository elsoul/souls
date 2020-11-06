require "erb"
require "grpc"
require "yaml"
require "active_record"
require "logger"

$LOAD_PATH << "#{Dir.pwd}/app/services"

Dir[File.expand_path "app/*.rb"].each do |file|
  require file
end
db_conf = YAML.safe_load(ERB.new(File.read("./config/database.yml")).result)
ActiveRecord::Base.establish_connection(db_conf)
