module Resolvers
  class BaseResolver < GraphQL::Schema::Resolver
    def decode_global_key(id)
      _, data_id = SOULsApiSchema.from_global_id(id)
      return 0 if data_id.to_i.to_s == data_id

      data_id
    end
  end
end
