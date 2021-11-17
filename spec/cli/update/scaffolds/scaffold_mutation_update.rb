module Scaffold
  def self.update_mutation_update
    <<~USER
      module Mutations
        module Base::User
          class UpdateUser < BaseMutation
            field :error, String, null: true
            field :user_edge, Types::UserType.edge_type, null: false

            argument :tel, String, required: false
            argument :uid, String, required: false
            argument :username, String, required: false

            def resolve(args)
              _, data_id = SoulsApiSchema.from_global_id(args[:id])
              new_record = { **args }
              data = ::User.find(data_id)
              data.update(new_record)
              raise(StandardError, data.errors.full_messages) unless data.save

              { user_edge: { node: data } }
            rescue StandardError => e
              GraphQL::ExecutionError.new(e.message)
            end
          end
        end
      end

    USER
  end

  def self.update_mutation_update_u
    <<~USER
      module Mutations
        module Base::User
          class UpdateUser < BaseMutation
            field :error, String, null: true
            field :user_edge, Types::UserType.edge_type, null: false

            argument :tel, String, required: false
            argument :test, , required: false
            argument :uid, String, required: false
            argument :username, String, required: false

            def resolve(args)
              _, data_id = SoulsApiSchema.from_global_id(args[:id])
              new_record = { **args }
              data = ::User.find(data_id)
              data.update(new_record)
              raise(StandardError, data.errors.full_messages) unless data.save

              { user_edge: { node: data } }
            rescue StandardError => e
              GraphQL::ExecutionError.new(e.message)
            end
          end
        end
      end

    USER
  end
end
