module Queries
  class Me < Queries::BaseQuery
    type Types::UserType, null: false

    def resolve
      ::User.find(context[:user].id)
    rescue StandardError => e
      GraphQL::ExecutionError.new(e)
    end
  end
end
