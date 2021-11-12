module Scaffold
  def self.update_mutation_create
    <<~USER
module Mutations
  module Base::User
    class CreateUser < BaseMutation
      field :error, String, null: true
      field :user_edge, Types::UserType.edge_type, null: false

      argument :tel, String, required: false
      argument :uid, String, required: false
      argument :username, String, required: false

      def resolve(args)
        new_record = { **args }
        data = ::User.new(new_record)
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

  def self.update_mutation_create_u
    <<~USERUPDATE
module Mutations
  module Base::User
    class CreateUser < BaseMutation
      field :error, String, null: true
      field :user_edge, Types::UserType.edge_type, null: false

      argument :tel, String, required: false
      argument :test, , required: false
      argument :uid, String, required: false
      argument :username, String, required: false

      def resolve(args)
        new_record = { **args }
        data = ::User.new(new_record)
        raise(StandardError, data.errors.full_messages) unless data.save

        { user_edge: { node: data } }
      rescue StandardError => e
        GraphQL::ExecutionError.new(e.message)
      end
    end
  end
end
    USERUPDATE
  end

  def self.update_mutation_create_arg
    <<~USERWITHARGUMENT
module Mutations
  module Base::Userargument
    class CreateUserargument < BaseMutation
      field :error, String, null: true
      field :userargument_edge, Types::UserType.edge_type, null: false

      argument :tel, String, required: false
      argument :test, , required: false
      argument :uid, String, required: false
      argument :username, String, required: false

      def resolve(args)
        new_record = { **args }
        data = ::User.new(new_record)
        raise(StandardError, data.errors.full_messages) unless data.save

        { user_edge: { node: data } }
      rescue StandardError => e
        GraphQL::ExecutionError.new(e.message)
      end
    end
  end
end
    USERWITHARGUMENT
  end

  def self.update_mutation_arg_u
    <<~USERUPDATE
module Mutations
  module Base::Userargument
    class CreateUserargument < BaseMutation
      field :error, String, null: true
      field :userargument_edge, Types::UserType.edge_type, null: false

      argument :tel, String, required: false
      argument :test, , required: false
      argument :uid, String, required: false
      argument :username, String, required: false

      def resolve(args)
        new_record = { **args }
        data = ::User.new(new_record)
        raise(StandardError, data.errors.full_messages) unless data.save

        { user_edge: { node: data } }
      rescue StandardError => e
        GraphQL::ExecutionError.new(e.message)
      end
    end
  end
end
    USERUPDATE
  end
end
