require_relative "./model"
require_relative "./model_rbs"
require_relative "./mutation"
require_relative "./mutation_rbs"
require_relative "./policy"
require_relative "./policy_rbs"
require_relative "./query"
require_relative "./query_rbs"
require_relative "./resolver"
require_relative "./resolver_rbs"
require_relative "./rspec_factory"
require_relative "./rspec_model"
require_relative "./rspec_mutation"
require_relative "./rspec_policy"
require_relative "./rspec_query"
require_relative "./rspec_resolver"
require_relative "./type"
require_relative "./type_rbs"
require_relative "./edge"
require_relative "./edge_rbs"
require_relative "./connection"
require_relative "./connection_rbs"
require_relative "./application"
require_relative "./manager"

# require_paths = []
# Dir["lib/souls/api/generate/*"].map do |n|
#   next if n.include?("index.rb")

#   require_paths << n.split("/").last.gsub(".rb", "")
# end
# require_paths.each do |path|
#   require_relative "./#{path}"
# end
