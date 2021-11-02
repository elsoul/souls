module Mutations
  module Base::User
    class CreateUser < BaseMutation
      field :user_edge, Types::UserType.edge_type, null: false
      field :error, String, null: true

        data = ::User.new(args)
        raise(StandardError, data.errors.full_messages) unless data.save

        { user_edge: { node: data } }
      rescue StandardError => error
        GraphQL::ExecutionError.new(error.message)
      end
    end
  end
end
