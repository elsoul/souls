module Queries
  class User < Queries::BaseQuery
    type Types::UserType, null: false
    argument :id, String, required: true

    def resolve(**args)
      _, data_id = SoulsApiSchema.from_global_id(args[:id])
      ::User.find(data_id)
    rescue StandardError => e
      GraphQL::ExecutionError.new(e)
    end
  end
end
