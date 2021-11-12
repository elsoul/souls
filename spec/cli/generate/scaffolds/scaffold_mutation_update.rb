module Scaffold
  def self.scaffold_mutation_update
    <<~MUTATIONUPDATE
module Mutations
  module Base::User
    class UpdateUser < BaseMutation
      field :user_edge, Types::UserType.edge_type, null: false
      field :error, String, null: true

      argument :id, String, required: true
        new_record = args.except(:id)
        data = ::User.find(data_id)
        data.update(new_record)
        raise(StandardError, data.errors.full_messages) unless data.save

        { user_edge: { node: data } }
      rescue StandardError => error
        GraphQL::ExecutionError.new(error.message)
      end
    end
  end
end
    MUTATIONUPDATE
  end
end
