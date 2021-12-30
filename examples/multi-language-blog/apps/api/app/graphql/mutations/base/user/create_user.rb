module Mutations
  module Base::User
    class CreateUser < BaseMutation
      field :error, String, null: true
      field :user_edge, Types::UserType.edge_type, null: false

      argument :email, String, required: false
      argument :is_deleted, Boolean, required: false
      argument :lang, String, required: false
      argument :uid, String, required: false
      argument :username, String, required: false

      def resolve(args)
        new_record = { **args }
        data = ::User.new(new_record)
        raise(StandardError, data.errors.full_messages) unless data.save

        { user_edge: { node: data } }
      end
    end
  end
end
