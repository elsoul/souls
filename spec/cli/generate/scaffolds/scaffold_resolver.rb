module Scaffold
  def self.scaffold_resolver
    <<~RESOLVER
      module Resolvers
        class UserSearch < Base
          include SearchObject.module(:graphql)
          scope { ::User.all }
          type Types::UserType.connection_type, null: false
          description "Search User"

          class UserFilter < ::Types::BaseInputObject
            argument :OR, [self], required: false
              argument :start_date, String, required: false
              argument :end_date, String, required: false
            end

            option :filter, type: UserFilter, with: :apply_filter
            option :first, type: types.Int, with: :apply_first
            option :skip, type: types.Int, with: :apply_skip

            def apply_filter(scope, value)
              branches = normalize_filters(value).inject { |a, b| a.or(b) }
              scope.merge branches
            end

            def normalize_filters(value, branches = [])
              scope = ::User.all
            scope = scope.where("created_at >= ?", value[:start_date]) if value[:start_date]
            scope = scope.where("created_at <= ?", value[:end_date]) if value[:end_date]
            branches << scope.order(created_at: :desc)
            value[:OR].inject(branches) { |s, v| normalize_filters(v, s) } if value[:OR].present?
            branches
          end
        end
      end
    RESOLVER
  end
end
