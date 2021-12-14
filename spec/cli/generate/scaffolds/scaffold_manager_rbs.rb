module Scaffold
  def self.scaffold_manager_rbs
    <<~MANAGERRBS
      module Mutations
        module Managers
          module UserManager < BaseMutation
            class User
              def self.description: (String)-> untyped
              def self.argument: (untyped, untyped, untyped)-> untyped
              def self.field: (untyped, untyped, untyped)-> untyped
            end
          end
        end
      end
    MANAGERRBS
  end
end
