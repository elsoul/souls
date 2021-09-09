require_relative "./model"
require_relative "./mutation"
require_relative "./policy"
require_relative "./query"
require_relative "./resolver"
require_relative "./rspec_factory"
require_relative "./rspec_model"
require_relative "./rspec_mutation"
require_relative "./rspec_policy"
require_relative "./rspec_query"
require_relative "./rspec_resolver"
require_relative "./type"
require_relative "./edge"
require_relative "./connection"
require_relative "./application"
require_relative "./migration"
require_relative "./manager"

# require_paths = []
# Dir["lib/souls/api/generate/*"].map do |n|
#   next if n.include?("index.rb")

#   require_paths << n.split("/").last.gsub(".rb", "")
# end
# require_paths.each do |path|
#   require_relative "./#{path}"
# end
