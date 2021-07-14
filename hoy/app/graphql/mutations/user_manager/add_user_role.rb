module Mutations
  module UserManager
    class AddUserRole < BaseMutation
      argument :target_user_id, String, required: true
      argument :user_roles, [String], required: true

      field :user, Types::UserType, null: true

      def resolve(**args)
        check_user_permissions(context[:user], context[:user], :update_user_role?)
        _, user_id = SoulsApiSchema.from_global_id(args[:target_user_id])
        target_user = ::User.find(user_id)
        target_user.roles << args[:user_roles].map(&:to_sym)
        return { user: target_user } if target_user.save

        raise
      rescue StandardError => e
        GraphQL::ExecutionError.new(e.to_s)
      end
    end
  end
end
