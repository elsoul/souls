module Souls
  module Generate
    class << self
      ## Common Methods
      def generated_paths class_name: "user"
        singularized_class_name = class_name.singularize.underscore
        pluralized_class_name = class_name.pluralize.underscore
        [
          "./app/models/#{singularized_class_name}.rb",
          "./app/policies/#{singularized_class_name}_policy.rb",
          "./app/graphql/mutations/create_#{singularized_class_name}.rb",
          "./app/graphql/mutations/delete_#{singularized_class_name}.rb",
          "./app/graphql/mutations/destroy_delete_#{singularized_class_name}.rb",
          "./app/graphql/mutations/update_#{singularized_class_name}.rb",
          "./app/graphql/queries/#{singularized_class_name}.rb",
          "./app/graphql/queries/#{pluralized_class_name}.rb",
          "./app/graphql/resolvers/#{singularized_class_name}_search.rb",
          "./app/graphql/types/#{singularized_class_name}_type.rb",
          "./app/graphql/types/#{singularized_class_name}_node_type.rb",
          "./spec/factories/#{pluralized_class_name}.rb",
          "./spec/mutations/#{singularized_class_name}_spec.rb",
          "./spec/models/#{singularized_class_name}_spec.rb",
          "./spec/queries/#{singularized_class_name}_spec.rb",
          "./spec/policies/#{singularized_class_name}_policy_spec.rb",
          "./spec/resolvers/#{singularized_class_name}_search_spec.rb"
        ]
      end

      def get_type_and_name line
        line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
      end

      def get_tables
        path = "./db/schema.rb"
        tables = []
        File.open(path, "r") do |f|
          f.each_line.with_index do |line, i|
              tables << line.split("\"")[1] if line.include?("create_table")
          end
        end
        tables
      end

      def test_dir
        FileUtils.mkdir_p "./app/graphql/mutations"
        FileUtils.mkdir_p "./app/graphql/queries"
        FileUtils.mkdir_p "./app/graphql/types"
        FileUtils.mkdir_p "./app/graphql/resolvers"
        FileUtils.mkdir_p "./app/models"
        FileUtils.mkdir_p "./app/policies"
        FileUtils.mkdir_p "./spec/factories"
        FileUtils.mkdir_p "./spec/queries"
        FileUtils.mkdir_p "./spec/mutations"
        FileUtils.mkdir_p "./spec/models"
        FileUtils.mkdir_p "./spec/resolvers"
        FileUtils.mkdir_p "./spec/policies"
        FileUtils.mkdir_p "./config"
        FileUtils.touch "./config/souls.rb"
        FileUtils.mkdir_p "./db/"
        FileUtils.touch "./db/schema.rb"
        puts "test dir created!"
      end

      def type_check type
        {
          bigint: "Integer",
          string: "String",
          float: "Float",
          text: "String",
          datetime: "GraphQL::Types::ISO8601DateTime",
          date: "GraphQL::Types::ISO8601DateTime",
          boolean: "Boolean",
          integer: "Integer"
        }[type.to_sym]
      end

      def get_test_type type
        {
          bigint: 1,
          float: 4.2,
          string: '"MyString"',
          text: '"MyString"',
          datetime: "Time.now",
          date: "Time.now",
          boolean: false,
          integer: 1
        }[type.to_sym]
      end

      def table_check line: "", class_name: ""
        if line.include?("create_table") && (line.split(" ")[1].gsub("\"", "").gsub(",", "") == class_name.pluralize.to_s)
          return true
        end
        false
      end

      def migrate class_name: "souls"
        singularized_class_name = class_name.singularize
        [
          model: model(class_name: singularized_class_name),
          types: type(class_name: singularized_class_name),
          resolver: resolver(class_name: singularized_class_name),
          rspec_factory: rspec_factory(class_name: singularized_class_name),
          rspec_model: rspec_model(class_name: singularized_class_name),
          rspec_mutation: rspec_mutation(class_name: singularized_class_name),
          rspec_query: rspec_query(class_name: singularized_class_name),
          rspec_resolver: rspec_resolver(class_name: singularized_class_name),
          queries: query(class_name: singularized_class_name),
          mutations: mutation(class_name: singularized_class_name),
          policies: policy(class_name: singularized_class_name),
          rspec_policies: rspec_policy(class_name: singularized_class_name)
        ]
      end

      def delete_all class_name: "souls"
        singularized_class_name = class_name.singularize.underscore
        pluralized_class_name = class_name.pluralize.underscore
        FileUtils.rm "./app/models/#{singularized_class_name}.rb"
        FileUtils.rm "./app/policies/#{singularized_class_name}_policy.rb"
        FileUtils.rm_rf "./app/graphql/mutations/#{singularized_class_name}"
        FileUtils.rm "./app/graphql/queries/#{singularized_class_name}.rb"
        FileUtils.rm "./app/graphql/queries/#{pluralized_class_name}.rb"
        FileUtils.rm "./app/graphql/resolvers/#{singularized_class_name}_search.rb"
        FileUtils.rm "./app/graphql/types/#{singularized_class_name}_type.rb"
        FileUtils.rm "./app/graphql/types/#{singularized_class_name}_node_type.rb"
        FileUtils.rm "./spec/factories/#{pluralized_class_name}.rb"
        FileUtils.rm "./spec/mutations/#{singularized_class_name}_spec.rb"
        FileUtils.rm "./spec/models/#{singularized_class_name}_spec.rb"
        FileUtils.rm "./spec/queries/#{singularized_class_name}_spec.rb"
        FileUtils.rm "./spec/policies/#{singularized_class_name}_policy_spec.rb"
        FileUtils.rm "./spec/resolvers/#{singularized_class_name}_search_spec.rb"
        puts "deleted #{class_name.camelize} CRUD!"
      rescue StandardError => error
        puts error
      end

      def single_migrate class_name: "user"
        puts "◆◆◆ Let's Auto Generate CRUD API SET ◆◆◆\n"
        migrate class_name: class_name
        puts "Generated #{class_name.camelize} CRUD Files\n"
        Souls::Generate.generated_paths(class_name: class_name).each { |f| puts f }
        puts "\nAll files created from ./db/schema.rb"
        puts "\n\n"
      end

      def migrate_all
        puts "◆◆◆ Let's Auto Generate CRUD API SET ◆◆◆\n"
        get_tables.each do |class_name|
          migrate class_name: class_name.singularize
          puts "Generated #{class_name.camelize} CRUD Files\n"
          Souls::Generate.generated_paths(class_name: class_name).each { |f| puts f }
          puts "\n"
        end
        puts "\nAll files created from ./db/schema.rb"
      end
    end
  end
end
