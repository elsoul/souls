module Resolvers
  class ArticleCategorySearch < Base
    include SearchObject.module(:graphql)
    scope { ::ArticleCategory.all }
    type Types::ArticleCategoryType.connection_type, null: false
    description "Search ArticleCategory"

    class ArticleCategoryFilter < ::Types::BaseInputObject
      argument :OR, [self], required: false
      argument :end_date, String, required: false
      argument :is_deleted, Boolean, required: false
      argument :name, String, required: false
      argument :start_date, String, required: false
      argument :tags, [String], required: false
    end

    option :filter, type: ArticleCategoryFilter, with: :apply_filter
    option :first, type: types.Int, with: :apply_first
    option :skip, type: types.Int, with: :apply_skip

    def apply_filter(scope, value)
      branches = normalize_filters(value).inject { |acc, elem| acc.or(elem) }
      scope.merge(branches)
    end

    def normalize_filters(value, branches = [])
      scope = ::ArticleCategory.all
      scope = scope.where(name: value[:name]) if value[:name]
      scope = scope.where("tags @> ARRAY[?]::text[]", value[:tags]) if value[:tags]
      scope = scope.where(is_deleted: value[:is_deleted]) unless value[:is_deleted].nil?
      scope = scope.where("created_at >= ?", value[:start_date]) if value[:start_date]
      scope = scope.where("created_at <= ?", value[:end_date]) if value[:end_date]

      branches << scope

      value[:OR].inject(branches) { |acc, elem| normalize_filters(elem, acc) } if value[:OR].present?

      branches
    end
  end
end
