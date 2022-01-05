module SOULs
  class Generate < Thor
    desc "query_rbs [CLASS_NAME]", "Generate GraphQL Query RBS"
    def query_rbs(class_name)
      single_query_rbs(class_name)
    end

    private

    def single_query_rbs(class_name)
      file_path = ""
      Dir.chdir(SOULs.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/queries/"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        singularized_class_name = class_name.underscore.singularize
        file_path = "#{file_dir}#{singularized_class_name}.rbs"
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            module Queries
              class BaseQuery
              end
              class #{singularized_class_name.camelize} < Queries::BaseQuery
                def resolve:  ({
                                id: String?
                              }) -> ( Hash[Symbol, ( String | Integer | bool )] | ::GraphQL::ExecutionError )

                def self.argument: (*untyped) -> String
                def self.type: (*untyped) -> String
              end
            end
          TEXT
        end
        SOULs::Painter.create_file(file_path.to_s)
      end
      file_path
    end
  end
end
