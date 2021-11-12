module Scaffold
  def self.scaffold_mutation_create
    <<~MUTATIONCREATE
module Mutations
  module Base::User
    class CreateUser < BaseMutation
      field :user_edge, Types::UserType.edge_type, null: false
      field :error, String, null: true

        data = ::User.new(args)
        raise(StandardError, data.errors.full_messages) unless data.save

        { user_edge: { node: data } }
      end
    end
  end
end
    MUTATIONCREATE
  end
end
