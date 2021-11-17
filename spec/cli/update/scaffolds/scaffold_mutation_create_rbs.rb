module Scaffold
  def self.scaffold_mutation_create_rbs
    <<~MUTATIONCREATERBS
      class Boolean
      end
      module Mutations
        module Base
          module User
            class CreateUser < BaseMutation
              String: String
              Boolean: Boolean
              Integer: Integer
              def resolve:  ({
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
    MUTATIONCREATERBS
  end

  def self.scaffold_mutation_create_rbs_u
    <<~MUTATIONCREATERBS
      class Boolean
      end
      module Mutations
        module Base
          module User
            class CreateUser < BaseMutation
              String: String
              Boolean: Boolean
              Integer: Integer
              def resolve:  ({
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
    MUTATIONCREATERBS
  end
end
