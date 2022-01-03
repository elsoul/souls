Dir["#{Souls::SOULS_PATH}/lib/souls/cli/create/template/ruby/*/index.rb"].each do |f|
  path = f.split("/").last(2)[0]
  require_relative "./#{path}/index"
end

module Ruby
end
