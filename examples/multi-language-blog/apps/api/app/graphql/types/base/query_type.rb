module Types
  class QueryType < SOULs::Types::BaseObject
    add_field(GraphQL::Types::Relay::HasNodeField)
    add_field(GraphQL::Types::Relay::HasNodesField)
    SOULsHelper.get_tables.each do |t|
      field t.singularize.underscore.to_s.to_sym, resolver: Object.const_get("Queries::#{t.singularize.camelize}")
      field "#{t.singularize.underscore}_search".to_sym,
            resolver: Object.const_get("Resolvers::#{t.singularize.camelize}Search")
      field t.pluralize.underscore.to_s.to_sym,
            Object.const_get("Types::#{t.singularize.camelize}Type").connection_type,
            null: true
    end
  end
end
