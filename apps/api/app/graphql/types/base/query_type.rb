module Types
  class QueryType < Types::BaseObject
    add_field(GraphQL::Types::Relay::NodeField)
    add_field(GraphQL::Types::Relay::NodesField)
    SoulsHelper.get_tables.each do |t|
      field t.singularize.underscore.to_s.to_sym, resolver: Object.const_get("Queries::#{t.singularize.camelize}")
      field "#{t.singularize.underscore}_search".to_sym,
            resolver: Object.const_get("Resolvers::#{t.singularize.camelize}Search")
      field t.pluralize.underscore.to_s.to_sym,
            Object.const_get("Types::#{t.singularize.camelize}Type").connection_type,
            null: true
      define_method t do
        Object.const_get(t.singularize.camelize.to_s).all.order(id: :desc)
      end
    end
    field :me, resolver: Queries::Me
  end
end
