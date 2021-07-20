module Queries
  class Users < Queries::BaseQuery
    type [Types::UserType], null: false

    def resolve
      ::User.all
    rescue StandardError => e
      GraphQL::ExecutionError.new(e)
    end
  end
end
