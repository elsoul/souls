module Souls
  module Api::Generate
    ## Common Methods
    def self.generated_paths(class_name: "user")
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
        "./app/graphql/types/edges/#{singularized_class_name}_edge.rb",
        "./app/graphql/types/connections/#{singularized_class_name}_connection.rb",
        "./spec/factories/#{pluralized_class_name}.rb",
        "./spec/mutations/#{singularized_class_name}_spec.rb",
        "./spec/models/#{singularized_class_name}_spec.rb",
        "./spec/queries/#{singularized_class_name}_spec.rb",
        "./spec/policies/#{singularized_class_name}_policy_spec.rb",
        "./spec/resolvers/#{singularized_class_name}_search_spec.rb"
      ]
    end

    def self.get_type_and_name(line)
      line.split(",")[0].gsub("\"", "").scan(/((?<=t\.).+(?=\s)) (.+)/)[0]
    end

    def self.get_tables
      path = "./db/schema.rb"
      tables = []
      File.open(path, "r") do |f|
        f.each_line.with_index do |line, _i|
          tables << line.split("\"")[1] if line.include?("create_table")
        end
      end
      tables
    end

    def self.test_dir
      FileUtils.mkdir_p("./app/graphql/mutations")
      FileUtils.mkdir_p("./app/graphql/queries")
      FileUtils.mkdir_p("./app/graphql/types")
      FileUtils.mkdir_p("./app/graphql/resolvers")
      FileUtils.mkdir_p("./app/models")
      FileUtils.mkdir_p("./app/policies")
      FileUtils.mkdir_p("./spec/factories")
      FileUtils.mkdir_p("./spec/queries")
      FileUtils.mkdir_p("./spec/mutations")
      FileUtils.mkdir_p("./spec/models")
      FileUtils.mkdir_p("./spec/resolvers")
      FileUtils.mkdir_p("./spec/policies")
      FileUtils.mkdir_p("./config")
      FileUtils.touch("./config/souls.rb")
      FileUtils.mkdir_p("./db/")
      FileUtils.touch("./db/schema.rb")
      puts("test dir created!")
    end

    def self.type_check(type)
      {
        bigint: "Integer",
        string: "String",
        float: "Float",
        text: "String",
        datetime: "String",
        date: "String",
        boolean: "Boolean",
        integer: "Integer"
      }[type.to_sym]
    end

    def self.get_type(type)
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

    def self.get_test_type(type)
      {
        bigint: "rand(1..10)",
        float: 4.2,
        string: '"MyString"',
        text: '"MyString"',
        datetime: "Time.now",
        date: "Time.now.strftime('%F')",
        boolean: false,
        integer: "rand(1..10)"
      }[type.to_sym]
    end

    def self.table_check(line: "", class_name: "")
      if line.include?("create_table") && (line.split[1].gsub("\"", "").gsub(",", "") == class_name.pluralize.to_s)

        return true
      end

      false
    end

    def self.migrate(class_name: "souls")
      singularized_class_name = class_name.singularize
      model(class_name: singularized_class_name)
      type(class_name: singularized_class_name)
      edge(class_name: singularized_class_name)
      connection(class_name: singularized_class_name)
      resolver(class_name: singularized_class_name)
      rspec_factory(class_name: singularized_class_name)
      rspec_model(class_name: singularized_class_name)
      rspec_mutation(class_name: singularized_class_name)
      rspec_query(class_name: singularized_class_name)
      rspec_resolver(class_name: singularized_class_name)
      query(class_name: singularized_class_name)
      mutation(class_name: singularized_class_name)
      policy(class_name: singularized_class_name)
      rspec_policy(class_name: singularized_class_name)
    rescue StandardError => e
      puts(e.backtrace)
      raise(StandardError, e)
    end

    def self.migrate_all
      puts(Paint["Let's Go SOULs AUTO CRUD Assist!\n", :cyan])
      Souls::Api::Generate.get_tables.each do |table|
        Souls::Api::Generate.migrate(class_name: table.singularize)
        puts(Paint["Generated #{table.camelize} CRUD Files\n", :yellow])
      end
    end

    def self.delete_all(class_name: "souls")
      singularized_class_name = class_name.singularize.underscore
      pluralized_class_name = class_name.pluralize.underscore
      FileUtils.rm("./app/models/#{singularized_class_name}.rb")
      FileUtils.rm("./app/policies/#{singularized_class_name}_policy.rb")
      FileUtils.rm_rf("./app/graphql/mutations/base/#{singularized_class_name}")
      FileUtils.rm("./app/graphql/queries/#{singularized_class_name}.rb")
      FileUtils.rm("./app/graphql/queries/#{pluralized_class_name}.rb")
      FileUtils.rm("./app/graphql/resolvers/#{singularized_class_name}_search.rb")
      FileUtils.rm("./app/graphql/types/#{singularized_class_name}_type.rb")
      FileUtils.rm("./app/graphql/types/edges/#{singularized_class_name}_edge.rb")
      FileUtils.rm("./app/graphql/types/connections/#{singularized_class_name}_connection.rb")
      FileUtils.rm("./spec/factories/#{pluralized_class_name}.rb")
      FileUtils.rm("./spec/mutations/base/#{singularized_class_name}_spec.rb")
      FileUtils.rm("./spec/models/#{singularized_class_name}_spec.rb")
      FileUtils.rm("./spec/queries/#{singularized_class_name}_spec.rb")
      FileUtils.rm("./spec/policies/#{singularized_class_name}_policy_spec.rb")
      FileUtils.rm("./spec/resolvers/#{singularized_class_name}_search_spec.rb")
      puts(Paint["deleted #{class_name.camelize} CRUD!", :yellow])
    rescue StandardError => e
      raise(StandardError, e)
    end

    def self.update_delete(class_name: "souls")
      singularized_class_name = class_name.singularize.underscore
      pluralized_class_name = class_name.pluralize.underscore
      FileUtils.rm_rf("./app/graphql/mutations/#{singularized_class_name}")
      FileUtils.rm("./app/graphql/queries/#{singularized_class_name}.rb")
      FileUtils.rm("./app/graphql/queries/#{pluralized_class_name}.rb")
      FileUtils.rm("./app/graphql/resolvers/#{singularized_class_name}_search.rb")
      FileUtils.rm("./app/graphql/types/#{singularized_class_name}_type.rb")
      FileUtils.rm("./app/graphql/types/edges/#{singularized_class_name}_edge.rb")
      FileUtils.rm("./app/graphql/types/connections/#{singularized_class_name}_connection.rb")
      FileUtils.rm("./spec/mutations/#{singularized_class_name}_spec.rb")
      FileUtils.rm("./spec/queries/#{singularized_class_name}_spec.rb")
      FileUtils.rm("./spec/resolvers/#{singularized_class_name}_search_spec.rb")
      puts("deleted #{class_name.camelize} CRUD!")
    rescue StandardError => e
      raise(StandardError, e)
    end
  end
end
