module Resolvers
  class ArticleSearch < BaseResolver
    include SearchObject.module(:graphql)
    scope { ::Article.all }
    type Types::ArticleType.connection_type, null: false
    description "Search Article"

    class ArticleFilter < Souls::Types::BaseInputObject
      argument :OR, [self], required: false
      argument :body, String, required: false
      argument :category, String, required: false
      argument :end_date, String, required: false
      argument :is_deleted, Boolean, required: false
      argument :published, Boolean, required: false
      argument :slug, String, required: false
      argument :start_date, String, required: false
      argument :tags, [String], required: false
      argument :title, String, required: false
    end

    option :filter, type: ArticleFilter, with: :apply_filter

    def apply_filter(scope, value)
      branches = normalize_filters(value).inject { |acc, elem| acc.or(elem) }
      scope.merge(branches)
    end

    def normalize_filters(value, branches = [])
      scope = ::Article.all
      scope = scope.where(title: value[:title]) if value[:title]
      scope = scope.where(body: value[:body]) if value[:body]
      scope = scope.where(category: value[:category]) if value[:category]
      scope = scope.where("tags @> ARRAY[?]::text[]", value[:tags]) if value[:tags]
      scope = scope.where(slug: value[:slug]) if value[:slug]
      scope = scope.where(published: value[:published]) unless value[:published].nil?
      scope = scope.where(is_deleted: value[:is_deleted]) unless value[:is_deleted].nil?
      scope = scope.where("created_at >= ?", value[:start_date]) if value[:start_date]
      scope = scope.where("created_at <= ?", value[:end_date]) if value[:end_date]
      branches << scope.order(created_at: :desc)
      value[:OR].inject(branches) { |acc, elem| normalize_filters(elem, acc) } if value[:OR].present?
      branches
    end
  end
end
