module Souls
  class Generate < Thor
    desc "scaffold [CLASS_NAME]", "Generate Scaffold from schema.rb"
    method_option :rbs, type: :boolean, aliases: "--rbs", default: false, desc: "Generates Only RBS Files"
    def scaffold(class_name)
      singularized_class_name = class_name.singularize
      if options[:rbs]
        run_rbs_scaffold(class_name: singularized_class_name)
      else
        run_scaffold(class_name: singularized_class_name)
      end
      true
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    desc "scaffold_all", "Generate Scaffold All Tables from schema.rb"
    method_option :rbs, type: :boolean, aliases: "--rbs", default: false, desc: "Generates Only RBS All Schema Files"
    def scaffold_all
      puts(Paint["Let's Go SOULs AUTO CRUD Assist!\n", :cyan])
      Souls.get_tables.each do |table|
        if options[:rbs]
          Souls::Generate.new.invoke(:scaffold, [table.singularize], { rbs: options[:rbs] })
        else
          Souls::Generate.new.invoke(:scaffold, [table.singularize], {})
        end
      end
      true
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    private

    def run_scaffold(class_name: "user")
      type(class_name)
      type_rbs(class_name)
      query(class_name)
      query_rbs(class_name)
      mutation(class_name)
      mutation_rbs(class_name)
      policy(class_name)
      policy_rbs(class_name)
      edge(class_name)
      edge_rbs(class_name)
      connection(class_name)
      connection_rbs(class_name)
      resolver(class_name)
      resolver_rbs(class_name)
      rspec_factory(class_name)
      rspec_mutation(class_name)
      rspec_query(class_name)
      rspec_resolver(class_name)
      rspec_policy(class_name)
    end

    def run_rbs_scaffold(class_name: "user")
      type_rbs(class_name)
      query_rbs(class_name)
      mutation_rbs(class_name)
      policy_rbs(class_name)
      edge_rbs(class_name)
      connection_rbs(class_name)
      resolver_rbs(class_name)
    end

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
