require_relative "./mutation"
require_relative "./mutation_rbs"
require_relative "./resolver"
require_relative "./type"
require_relative "./type_rbs"
require_relative "./rspec_factory"
require_relative "./rspec_mutation"
require_relative "./rspec_resolver"

module Souls
  class Update < Thor
    desc "scaffold [CLASS_NAME]", "Update Scaffold Params"
    def scaffold(_class_name)
      invoke(:create_mutation)
      invoke(:update_mutation)
      invoke(:create_mutation_rbs)
      invoke(:update_mutation_rbs)
      invoke(:resolver)
      invoke(:type)
      invoke(:type_rbs)
      invoke(:rspec_factory)
      invoke(:rspec_mutation)
      invoke(:rspec_resolver)
    end
  end
end
