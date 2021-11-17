module Scaffold
  def self.scaffold_query
    <<~QUERY
      module Queries
        class Users < Queries::BaseQuery
          type [Types::UserType], null: false

          def resolve
            ::User.all
          end
        end
      end
    QUERY
  end

  def self.scaffold_individual_query
    <<~QUERY
      module Queries
        class User < Queries::BaseQuery
          type Types::UserType, null: false
          argument :id, String, required: true

          def resolve args
            _, data_id = SoulsApiSchema.from_global_id args[:id]
            ::User.find(data_id)
          end
        end
      end
    QUERY
  end
end
