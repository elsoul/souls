module Resolvers
  class UserSearch < Base
    include SearchObject.module(:graphql)
    scope { ::User.all }
    type Types::UserType.connection_type, null: false
    description "Search User"

    class UserFilter < ::Types::BaseInputObject
      argument :OR, [self], required: false
      argument :birthday, String, required: false
      argument :email, String, required: false
      argument :end_date, String, required: false
      argument :first_name, String, required: false
      argument :first_name_kana, String, required: false
      argument :first_name_kanji, String, required: false
      argument :icon_url, String, required: false
      argument :is_deleted, Boolean, required: false
      argument :last_name, String, required: false
      argument :last_name_kana, String, required: false
      argument :last_name_kanji, String, required: false
      argument :screen_name, String, required: false
      argument :start_date, String, required: false
      argument :tel, String, required: false
      argument :uid, String, required: false
      argument :username, String, required: false
    end

    option :filter, type: UserFilter, with: :apply_filter
    option :first, type: types.Int, with: :apply_first
    option :skip, type: types.Int, with: :apply_skip

    def apply_filter(scope, value)
      branches = normalize_filters(value).inject { |acc, elem| acc.or(elem) }
      scope.merge(branches)
    end

    def normalize_filters(value, branches = [])
      scope = ::User.all
      scope = scope.where(uid: value[:uid]) if value[:uid]
      scope = scope.where(username: value[:username]) if value[:username]
      scope = scope.where(screen_name: value[:screen_name]) if value[:screen_name]
      scope = scope.where(last_name: value[:last_name]) if value[:last_name]
      scope = scope.where(first_name: value[:first_name]) if value[:first_name]
      scope = scope.where(last_name_kanji: value[:last_name_kanji]) if value[:last_name_kanji]
      scope = scope.where(first_name_kanji: value[:first_name_kanji]) if value[:first_name_kanji]
      scope = scope.where(last_name_kana: value[:last_name_kana]) if value[:last_name_kana]
      scope = scope.where(first_name_kana: value[:first_name_kana]) if value[:first_name_kana]
      scope = scope.where(email: value[:email]) if value[:email]
      scope = scope.where(tel: value[:tel]) if value[:tel]
      scope = scope.where(icon_url: value[:icon_url]) if value[:icon_url]
      scope = scope.where(birthday: value[:birthday]) if value[:birthday]
      scope = scope.where(is_deleted: value[:is_deleted]) unless value[:is_deleted].nil?
      scope = scope.where("created_at >= ?", value[:start_date]) if value[:start_date]
      scope = scope.where("created_at <= ?", value[:end_date]) if value[:end_date]

      branches << scope

      value[:OR].inject(branches) { |acc, elem| normalize_filters(elem, acc) } if value[:OR].present?

      branches
    end
  end
end
