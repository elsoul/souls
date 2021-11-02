module OutputScaffold
  def self.scaffold_query_rbs
    <<~QUERYRBS
module Queries
  class BaseQuery
  end
  class User < Queries::BaseQuery
    def resolve:  ({
                    id: String?
                  }) -> ( Hash[Symbol, ( String | Integer | bool )] | ::GraphQL::ExecutionError )

    def self.argument: (*untyped) -> String
    def self.type: (*untyped) -> String
  end
end
    QUERYRBS
  end
end
