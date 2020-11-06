require "./config/initialize"

Dir[File.expand_path "./app/models/*.rb"].sort.each do |file|
  require file
end
