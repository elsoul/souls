module Mutations
  module Base::User
    class UpdateUser < BaseMutation
      field :error, String, null: true
      field :user_edge, Types::UserType.edge_type, null: false

      argument :email, String, required: false
      argument :id, String, required: true
      argument :is_deleted, Boolean, required: false
      argument :lang, String, required: false
      argument :uid, String, required: false
      argument :username, String, required: false

      def resolve(args)
        _, data_id = SOULsApiSchema.from_global_id(args[:id])
        new_record = { **args, id: data_id }
        data = ::User.find(data_id)
        data.update(new_record)
        raise(StandardError, data.errors.full_messages) unless data.save

        { user_edge: { node: data } }
      end
    end
  end
end
