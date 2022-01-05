module Resolvers
  class ArticleTranslationSearch < BaseResolver
    include SearchObject.module(:graphql)
    scope { ::ArticleTranslation.all }
    type Types::ArticleTranslationType.connection_type, null: false
    description "Search ArticleTranslation"

    class ArticleTranslationFilter < SOULs::Types::BaseInputObject
      argument :OR, [self], required: false
      argument :article_id, String, required: false
      argument :body, String, required: false
      argument :end_date, String, required: false
      argument :is_deleted, Boolean, required: false
      argument :start_date, String, required: false
      argument :title, String, required: false
    end

    option :filter, type: ArticleTranslationFilter, with: :apply_filter

    def apply_filter(scope, value)
      branches = normalize_filters(value).inject { |acc, elem| acc.or(elem) }
      scope.merge(branches)
    end

    def normalize_filters(value, branches = [])
      scope = ::ArticleTranslation.all
      scope = scope.where(article_id: decode_global_key(value[:article_id])) if value[:article_id]
      scope = scope.where(title: value[:title]) if value[:title]
      scope = scope.where(body: value[:body]) if value[:body]
      scope = scope.where(is_deleted: value[:is_deleted]) unless value[:is_deleted].nil?
      scope = scope.where("created_at >= ?", value[:start_date]) if value[:start_date]
      scope = scope.where("created_at <= ?", value[:end_date]) if value[:end_date]
      branches << scope.order(created_at: :desc)
      value[:OR].inject(branches) { |acc, elem| normalize_filters(elem, acc) } if value[:OR].present?
      branches
    end
  end
end
