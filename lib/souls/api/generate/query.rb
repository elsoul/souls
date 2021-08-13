module Souls
  module Api::Generate
    ## Generate Query / Queries
    def self.create_queries(class_name: "souls")
      file_path = "./app/graphql/queries/#{class_name.pluralize}.rb"
      return "Query already exist! #{file_path}" if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
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
        TEXT
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue StandardError => e
      raise(StandardError, e)
    end

    def self.create_query(class_name: "souls")
      file_path = "./app/graphql/queries/#{class_name}.rb"
      return "Query already exist! #{file_path}" if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
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
        TEXT
        puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
        file_path
      rescue StandardError => e
        raise(StandardError, e)
      end
    end

    def self.query(class_name: "souls")
      file_dir = "./app/graphql/queries/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      singularized_class_name = class_name.singularize
      create_query(class_name: singularized_class_name)
      create_queries(class_name: singularized_class_name)
    rescue StandardError => e
      raise(StandardError, e)
    end
  end
end
