module Souls
  class Generate < Thor
    desc "resolver_rbs [CLASS_NAME]", "Generate GraphQL Resolver RBS from schema.rb"
    def resolver_rbs(class_name)
      singularized_class_name = class_name.underscore.singularize
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/resolvers"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        file_path = "#{file_dir}/#{singularized_class_name}_search.rbs"
        raise(Thor::Error, "Mutation RBS already exist! #{file_path}") if File.exist?(file_path)

        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            class Base
            end
            class #{singularized_class_name.camelize}Search < Base
              include SearchObject
              def self.scope: () ?{ () -> nil } -> [Hash[Symbol, untyped]]
              def self.type: (*untyped) -> String
              def self.option: (:filter, type: untyped, with: :apply_filter) -> String
                              | (:first, type: untyped, with: :apply_first) -> String
                              | (:skip, type: untyped, with: :apply_skip) -> String
              def self.description: (String) -> String
              def self.types: (*untyped) -> String
              def decode_global_key: (String value) -> Integer
              def apply_filter: (untyped scope, untyped value) -> untyped

              class #{singularized_class_name.camelize}Filter
                String: String
                Boolean: Boolean
                Integer: Integer
              end
            end
          TEXT
        end
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    end
  end
end
