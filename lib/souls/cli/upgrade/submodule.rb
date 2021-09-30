module Souls
  class Upgrade < Thor
    desc "submodule", "Run git submodule update --init RBS collection"
    def submodule
      system("git submodule update --init https://github.com/ruby/gem_rbs_collection.git vendor/rbs/gem_rbs_collection")
    end
  end
end