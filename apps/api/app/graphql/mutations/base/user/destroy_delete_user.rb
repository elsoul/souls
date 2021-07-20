module Mutations
  module Base::User
    class DestroyDeleteUser < BaseMutation
      field :user, Types::UserType, null: false
      argument :id, String, required: true

      def resolve(**args)
        _, data_id = SoulsApiSchema.from_global_id(args[:id])
        user = ::User.find(data_id)
        user.destroy
        { user: user }
      rescue StandardError => e
        GraphQL::ExecutionError.new(e)
      end
    end
  end
end
