module OutputScaffold
  def self.scaffold_mutation_update_rbs
    <<~MUTATIONUPDATERBS
module Mutations
  module Base
    module User
      class UpdateUser < BaseMutation
        String: String
        Boolean: Boolean
        Integer: Integer
        def resolve:  ({
                        id: String,
                      }) -> ({ :user_edge => { :node => String } } | ::GraphQL::ExecutionError )


        def self.field: (*untyped) -> String
        attr_accessor context: {user:{
          id: Integer,
          username: String,
          email: String
        }}
      end
    end
  end
end
    MUTATIONUPDATERBS
  end
end
