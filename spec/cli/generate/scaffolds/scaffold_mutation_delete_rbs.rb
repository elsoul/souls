module Scaffold
  def self.scaffold_mutation_delete_rbs
    <<~MUTATIONDELETERBS
      module Mutations
        module Base
          module User
            class DeleteUser
              def resolve:  ({
                                id: String
                             }) -> ( Hash[Symbol, untyped] | ::GraphQL::ExecutionError )
      #{'        '}
              def self.argument: (*untyped) -> String
              def self.field: (*untyped) -> String
            end
          end
        end
      end
    MUTATIONDELETERBS
  end
end
