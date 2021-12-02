module Resolvers
  class BaseResolver < GraphQL::Schema::Resolver
    def decode_global_key(id)
      _, data_id = SoulsApiSchema.from_global_id(id)
      data_id
    end
  end
end
