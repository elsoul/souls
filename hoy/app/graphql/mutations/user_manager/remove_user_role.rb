module Mutations
  module UserManager
    class RemoveUserRole < BaseMutation
      argument :target_user_id, String, required: true
      argument :user_roles, [String], required: true

      field :user, Types::UserType, null: true

      def resolve(**args)
        check_user_permissions(context[:user], context[:user], :update_user_role?)
        _, user_id = SoulsApiSchema.from_global_id(args[:target_user_id])
        target_user = ::User.find(user_id)
        args[:user_roles].each { |role| target_user.roles.delete(role) }
        return { user: target_user } if target_user.save

        raise
      rescue StandardError => e
        GraphQL::ExecutionError.new(e.to_s)
      end
    end
  end
end
