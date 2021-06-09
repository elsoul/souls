# Did not work client side
# Dir["#{__dir__}/lib/souls/generate/*.rb"].each { |f| require_relative f.gsub("./lib/souls", ".")}
require_relative "./generate/model"
require_relative "./generate/mutation"
require_relative "./generate/policy"
require_relative "./generate/query"
require_relative "./generate/resolver"
require_relative "./generate/rspec_factory"
require_relative "./generate/rspec_model"
require_relative "./generate/rspec_mutation"
require_relative "./generate/rspec_policy"
require_relative "./generate/rspec_query"
require_relative "./generate/rspec_resolver"
require_relative "./generate/type"
require_relative "./generate/application"

module Souls
  module Generate
  end
end
