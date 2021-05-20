Dir["./lib/souls/generate/*.rb"].each { |f| require_relative f.gsub("./lib/souls/generate/", "") }
module Souls
  module Generate
  end
end
