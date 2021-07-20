module Types
  class BaseConnection < GraphQL::Types::Relay::BaseConnection
    field :total_count, Integer, null: false
    field :total_pages, Integer, null: false

    def total_count
      object.items.size
    end

    def total_pages
      total_count / object.max_page_size + 1
    end
  end
end
