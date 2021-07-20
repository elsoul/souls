module Resolvers
  class Base < GraphQL::Schema::Resolver
    # argument_class Arguments::Base
    def decode_global_key(id)
      _, data_id = SoulsApiSchema.from_global_id(id)
      data_id
    end

    def apply_first(scope, value)
      scope.limit(value)
    end

    def apply_skip(scope, value)
      scope.offset(value)
    end
  end
end
