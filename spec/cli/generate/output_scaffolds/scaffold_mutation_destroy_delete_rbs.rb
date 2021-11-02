module OutputScaffold
  def self.scaffold_mutation_dd_rbs
    <<~MUTATIONDDRBS
module Mutations
  module Base
    module User
      class DestroyDeleteUser
        def resolve:  ({
                          id: String
                       }) -> ( Hash[Symbol, untyped] | ::GraphQL::ExecutionError )
        
        def self.argument: (*untyped) -> String
        def self.field: (*untyped) -> String
      end
    end
  end
end
    MUTATIONDDRBS
  end
end
