module Souls
  class Generate < Thor
    desc "query [CLASS_NAME]", "Generate GraphQL Query from schema.rb"
    def query(class_name)
      file_dir = "./app/graphql/queries/"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      singularized_class_name = class_name.singularize
      create_individual_query(class_name: singularized_class_name)
    end

    private

    def create_individual_query(class_name: "user")
      file_path = "./app/graphql/queries/#{class_name}.rb"
      return "Query already exist! #{file_path}" if File.exist?(file_path)

      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Queries
            class #{class_name.camelize} < Queries::BaseQuery
              type Types::#{class_name.camelize}Type, null: false
              argument :id, String, required: true

              def resolve args
                _, data_id = SoulsApiSchema.from_global_id args[:id]
                ::#{class_name.camelize}.find(data_id)
              end
            end
          end
        TEXT
        Souls::Painter.create_file(file_path.to_s)
        file_path
      rescue StandardError => e
        raise(StandardError, e)
      end
    end
  end
end
