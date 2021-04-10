module Souls
  module Generate
    class << self
      ## Generate 2 Types
      ## 1. Type
      ## 2. Node Type
      def create_type_head class_name: "souls"
        file_path = "./app/graphql/types/#{class_name}_type.rb"
          File.open(file_path, "w") do |f|
            f.write <<~EOS
              module Types
                class #{class_name.camelize}Type < BaseObject
                  implements GraphQL::Types::Relay::Node

            EOS
          end
      end

      def create_type_params class_name: "souls"
        file_path = "./app/graphql/types/#{class_name}_type.rb"
        path = "./db/schema.rb"
        @on = false
        File.open(file_path, "a") do |new_line|
          File.open(path, "r") do |f|
            f.each_line.with_index do |line, i|
              if @on
                new_line.write "\n" && break if line.include?("end") || line.include?("t.index")
                field = "[String]" if line.include?("array: true")
                type, name = line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
                field ||= type_check type
                case name
                when /$*_id\z/
                  new_line.write "    field :#{name.gsub("_id", "")}, Types::#{name.gsub("_id", "").singularize.camelize}Type, null: false\n"
                else
                  new_line.write "    field :#{name}, #{field}, null: true\n"
                end
              end
              if table_check(line: line, class_name: class_name)
                @on = true
                new_line.write "    global_id_field :id\n"
              end
            end
          end
        end
      end

      def create_type_end class_name: "souls"
        file_path = "./app/graphql/types/#{class_name}_type.rb"
        File.open(file_path, "a") do |f|
          f.write <<~EOS
              end
            end
          EOS
        end
        file_path
      end

      def node_type class_name: "souls"
        file_path = "./app/graphql/types/#{class_name.singularize}_node_type.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            module Types
              class #{class_name.camelize}NodeType < BaseObject
                field :node, Types::#{class_name.camelize}Type, null: true
              end
            end
          EOS
        end
        file_path
      end

      def type class_name: "souls"
        singularized_class_name = class_name.singularize
        create_type_head class_name: singularized_class_name
        create_type_params class_name: singularized_class_name
        [
          create_type_end(class_name: singularized_class_name),
          node_type(class_name: singularized_class_name)
        ]
      end
    end
  end
end
