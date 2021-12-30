module Resolvers
  class UserSearch < BaseResolver
    include SearchObject.module(:graphql)
    scope { ::User.all }
    type Types::UserType.connection_type, null: false
    description "Search User"

    class UserFilter < Souls::Types::BaseInputObject
      argument :OR, [self], required: false
      argument :email, String, required: false
      argument :end_date, String, required: false
      argument :is_deleted, Boolean, required: false
      argument :lang, String, required: false
      argument :start_date, String, required: false
      argument :uid, String, required: false
      argument :username, String, required: false
    end

    option :filter, type: UserFilter, with: :apply_filter

    def apply_filter(scope, value)
      branches = normalize_filters(value).inject { |acc, elem| acc.or(elem) }
      scope.merge(branches)
    end

    def normalize_filters(value, branches = [])
      scope = ::User.all
      scope = scope.where(uid: value[:uid]) if value[:uid]
      scope = scope.where(username: value[:username]) if value[:username]
      scope = scope.where(email: value[:email]) if value[:email]
      scope = scope.where(lang: value[:lang]) if value[:lang]
      scope = scope.where(is_deleted: value[:is_deleted]) unless value[:is_deleted].nil?
      scope = scope.where("created_at >= ?", value[:start_date]) if value[:start_date]
      scope = scope.where("created_at <= ?", value[:end_date]) if value[:end_date]
      branches << scope.order(created_at: :desc)
      value[:OR].inject(branches) { |acc, elem| normalize_filters(elem, acc) } if value[:OR].present?
      branches
    end
  end
end
