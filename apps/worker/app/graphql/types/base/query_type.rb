module Types
  class QueryType < Types::BaseObject
    add_field(GraphQL::Types::Relay::NodeField)
    add_field(GraphQL::Types::Relay::NodesField)
    workers =
      Dir["./app/graphql/queries/*.rb"].map do |file|
        file.gsub("./app/graphql/queries/", "").gsub(".rb", "")
      end
    workers.delete("base_query")
    workers.each do |worker|
      field worker.underscore.to_s.to_sym,
            resolver: Object.const_get("Queries::#{worker.singularize.camelize}")
    end
  end
end
