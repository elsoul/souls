module Souls
  module Generate
    class << self
      ## Generate Query / Queries
      def create_queries class_name: "souls"
        file_path = "./app/graphql/queries/#{class_name.pluralize}.rb"
        return "Query already exist! #{file_path}" if File.exist? file_path
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            module Queries
              class #{class_name.camelize.pluralize} < Queries::BaseQuery
                type [Types::#{class_name.camelize}Type], null: false

                def resolve
                  ::#{class_name.camelize}.all
                rescue StandardError => error
                  GraphQL::ExecutionError.new error
                end
              end
            end
          EOS
        end
        file_path
      end

      def create_query class_name: "souls"
        file_path = "./app/graphql/queries/#{class_name}.rb"
        File.open(file_path, "w") do |f|
          f.write <<~EOS
            module Queries
              class #{class_name.camelize} < Queries::BaseQuery
                type Types::#{class_name.camelize}Type, null: false
                argument :id, String, required: true

                def resolve **args
                  _, data_id = SoulsApiSchema.from_global_id args[:id]
                  ::#{class_name.camelize}.find(data_id)
                rescue StandardError => error
                  GraphQL::ExecutionError.new error
                end
              end
            end
          EOS
          file_path
        end
      end

      def query class_name: "souls"
        singularized_class_name = class_name.singularize
        [
          create_query(class_name: singularized_class_name),
          create_queries(class_name: singularized_class_name)
        ]
      end
    end
  end
end
