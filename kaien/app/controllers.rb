Dir[File.expand_path "./app/controllers/*.rb"].sort.each do |file|
  require file
end
