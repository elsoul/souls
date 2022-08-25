require_relative "./mutation"
require_relative "./resolver"
require_relative "./type"
require_relative "./rspec_factory"
require_relative "./rspec_mutation"
require_relative "./rspec_resolver"

module SOULs
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
    end
  end
end
