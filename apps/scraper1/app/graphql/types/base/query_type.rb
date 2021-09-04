module Types
  class QueryType < Types::BaseObject
    add_field(GraphQL::Types::Relay::NodeField)
    add_field(GraphQL::Types::Relay::NodesField)
  end
end
