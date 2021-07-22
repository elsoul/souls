module Resolvers
  class ArticleSearch < Base
    include SearchObject.module(:graphql)
    scope { ::Article.all }
    type Types::ArticleType.connection_type, null: false
    description "Search Article"

    class ArticleFilter < ::Types::BaseInputObject
      argument :OR, [self], required: false
      argument :article_category_id, String, required: false
      argument :body, String, required: false
      argument :end_date, String, required: false
      argument :is_deleted, Boolean, required: false
      argument :is_public, Boolean, required: false
      argument :just_created, Boolean, required: false
      argument :public_date, GraphQL::Types::ISO8601DateTime, required: false
      argument :slag, String, required: false
      argument :start_date, String, required: false
      argument :tags, [String], required: false
      argument :thumnail_url, String, required: false
      argument :title, String, required: false
    end

    option :filter, type: ArticleFilter, with: :apply_filter
    option :first, type: types.Int, with: :apply_first
    option :skip, type: types.Int, with: :apply_skip

    def apply_filter(scope, value)
      branches = normalize_filters(value).inject { |acc, elem| acc.or(elem) }
      scope.merge(branches)
    end

    def normalize_filters(value, branches = [])
      scope = ::Article.all
      scope = scope.where(title: value[:title]) if value[:title]
      scope = scope.where(body: value[:body]) if value[:body]
      scope = scope.where(thumnail_url: value[:thumnail_url]) if value[:thumnail_url]
      scope = scope.where(public_date: value[:public_date]) if value[:public_date]
      if value[:article_category_id]
        scope = scope.where(article_category_id: decode_global_key(value[:article_category_id]))
      end
      scope = scope.where(is_public: value[:is_public]) unless value[:is_public].nil?
      scope = scope.where(just_created: value[:just_created]) unless value[:just_created].nil?
      scope = scope.where(slag: value[:slag]) if value[:slag]
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
