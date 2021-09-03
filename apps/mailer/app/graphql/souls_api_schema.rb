class SoulsApiSchema < GraphQL::Schema
  default_max_page_size 100
  mutation(Types::MutationType)
  query(Types::QueryType)
  use GraphQL::Batch

  def self.id_from_object(object, _type_definition, _query_ctx)
    # Call your application"s UUID method here
    # It should return a string
    to_global_id(object.class.name, object.id)
  end

  def self.object_from_id(id, _query_ctx)
    class_name, item_id = from_global_id(id)

    # "Post" => Post.find(item_id)
    Object.const_get(class_name).find(item_id)
  end

  def self.resolve_type(_type, obj, _ctx)
    case obj
    when Article
      Types::ArticleType
    when User
      Types::UserType
    when ArticleCategory
      Types::ArticleCategoryType
    when JobConsole
      Types::JobConsoleType
    else
      GraphQL::ExecutionError.new("Unexpected object: #{obj}")
    end
  end

  def self.to_global_id(class_name, item_id)
    Base64.strict_encode64("#{class_name}:#{item_id}")
  end

  def self.from_global_id(global_id)
    token = Base64.decode64(global_id)
    token.split(":")
  end
end
