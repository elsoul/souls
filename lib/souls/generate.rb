module Souls
  module Init
    class << self
    def node_type class_name: "souls"
      file_path = "./app/graphql/types/#{class_name.singularize}_node_type.rb"
      File.open(file_path, "w") do |f|
        f.write <<~EOS
          module Types
            class #{class_name.camelize}NodeType < GraphQL::Schema::Object
              field :node, Types::#{class_name.camelize}, null: true
            end
          end
        EOS
      end
      [file_path]
    end
    end
  end
end