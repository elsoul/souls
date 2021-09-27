module Souls
  class Generate < Thor
    desc "scaffold [CLASS_NAME]", "Generate Scaffold from schema.rb"
    method_option :mutation, type: :boolean, aliases: "--rbs", desc: "Mutation File Name"
    def scaffold(class_name)
      singularized_class_name = class_name.singularize
      model(singularized_class_name)
      model_rbs(singularized_class_name)
      type(singularized_class_name)
      type_rbs(singularized_class_name)
      query(singularized_class_name)
      query_rbs(singularized_class_name)
      mutation(singularized_class_name)
      mutation_rbs(singularized_class_name)
      policy(singularized_class_name)
      policy_rbs(singularized_class_name)
      edge(singularized_class_name)
      edge_rbs(singularized_class_name)
      connection(singularized_class_name)
      connection_rbs(singularized_class_name)
      resolver(singularized_class_name)
      resolver_rbs(singularized_class_name)
      rspec_factory(singularized_class_name)
      rspec_model(singularized_class_name)
      rspec_mutation(singularized_class_name)
      rspec_query(singularized_class_name)
      rspec_resolver(singularized_class_name)
      rspec_policy(singularized_class_name)
      true
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "scaffold_all", "Generate Scaffold All Tables from schema.rb"
    def scaffold_all
      puts(Paint["Let's Go SOULs AUTO CRUD Assist!\n", :cyan])
      Souls.get_tables.each do |table|
        Souls::Generate.new.scaffold(table.singularize)
        puts(Paint["Generated #{table.camelize} CRUD Files\n", :yellow])
      end
      true
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "delete_all  [CLASS_NAME]", "Generate Scaffold All Tables from schema.rb"
    def delete_all(class_name)
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
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    private

    def generated_paths(class_name: "user")
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

    def test_dir
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
  end
end
