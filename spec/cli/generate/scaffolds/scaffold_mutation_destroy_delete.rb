module Scaffold
  def self.scaffold_mutation_dd
    <<~MUTATIONDD
module Mutations
  module Base::User
    class DestroyDeleteUser < BaseMutation
      field :user, Types::UserType, null: false
      argument :id, String, required: true

      def resolve args
        _, data_id = SoulsApiSchema.from_global_id args[:id]
        user = ::User.find data_id
        user.destroy
        { user: user }
      end
    end
  end
end
MUTATIONDD
  end
end
