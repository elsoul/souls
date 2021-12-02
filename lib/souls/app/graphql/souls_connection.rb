module Souls
  class SoulsConnection < GraphQL::Types::Relay::BaseConnection
    field :total_count, Integer, null: false do
      description "Total number of items"
    end
    field :total_pages, Integer, null: false do
      description "Total number of pages"
    end

    def total_count
      object.items.size
    end

    def total_pages
      (total_count / object.max_page_size) + 1
    end
  end
end
