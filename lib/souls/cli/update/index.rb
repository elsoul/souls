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
    def scaffold(class_name)
      create_mutation(class_name)
      update_mutation(class_name)
      resolver(class_name)
      type(class_name)
      rspec_factory(class_name)
      rspec_mutation(class_name)
      rspec_resolver(class_name)
      Dir.chdir(Souls.get_mother_path.to_s) do
        create_mutation_rbs(class_name)
        update_mutation_rbs(class_name)
        type_rbs(class_name)
      end
    end
  end
end
