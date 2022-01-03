Dir["#{Souls::SOULS_PATH}/lib/souls/cli/create/template/ruby/ruby27/*"].each do |f|
  next if f.split("/").last == "index.rb"

  path = f.split("/").last.gsub(".rb", "")
  require_relative "./#{path}"
end

module Ruby27
end
