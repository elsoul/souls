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

        params = Souls.get_relation_params(class_name: singularized_class_name, col: "mutation")
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            class Base
            end
            class #{singularized_class_name.camelize}Search < Base
              def self.scope: () ?{ () -> nil } -> [Hash[Symbol, untyped]]
              def self.type: (*untyped) -> String
              def self.option: (:filter, type: untyped, with: :apply_filter) -> String
                              | (:first, type: untyped, with: :apply_first) -> String
                              | (:skip, type: untyped, with: :apply_skip) -> String
              def self.description: (String) -> String
              def self.types: (*untyped) -> String
              def decode_global_key: (String value) -> Integer
              def apply_filter: (untyped scope, untyped value) -> untyped
              def normalize_filters: (untyped value, ?Array[untyped] branches) -> Array[untyped]

              class #{singularized_class_name.camelize}Filter
                String: String
                Boolean: Boolean
                Integer: Integer
          TEXT
        end
        File.open(file_path, "a") do |f|
          params[:params].each_with_index do |param, i|
            type = Souls.rbs_type_check(param[:type])
            type = "[#{type}]" if param[:array]
            rbs_type = Souls.rbs_type_check(param[:type])
            if i.zero?
              f.write("    def self.argument: (:OR, [self], required: false) -> String\n")
            else
              f.write("                     | (:#{param[:column_name]}, #{type}, required: false) -> #{rbs_type}\n")
            end
          end
        end

        File.open(file_path, "a") do |f|
          f.write(<<~TEXT)
                end
              end
            end
            module Types
              class BaseBaseInputObject
              end
            end
          TEXT
        end
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
