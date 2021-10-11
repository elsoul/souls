require_relative "./mutation"
require_relative "./mutation_rbs"
require_relative "./resolver"
require_relative "./type"
require_relative "./rspec_factory"
require_relative "./rspec_mutation"
require_relative "./rspec_resolver"

module Souls
  class Update < Thor
    desc "scaffold [CLASS_NAME]", "Update Scaffold Params"
    def scaffold(_class_name)
      invoke(:create_mutation)
      invoke(:update_mutation)
      invoke(:resolver)
      invoke(:type)
      invoke(:rspec_factory)
      invoke(:rspec_mutation)
      invoke(:rspec_resolver)
    end
  end
end
