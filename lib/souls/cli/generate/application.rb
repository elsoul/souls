module SOULs
  class Generate < Thor
    desc "scaffold [CLASS_NAME]", "Generate Scaffold from schema.rb"
    def scaffold(class_name)
      singularized_class_name = class_name.singularize
      run_scaffold(singularized_class_name)
      true
    end

    desc "scaffold_all", "Generate Scaffold All Tables from schema.rb"
    def scaffold_all
      puts(Paint["Let's Go SOULs AUTO CRUD Assist!\n", :cyan])
      SOULs.get_tables.each do |table|
        SOULs::Generate.new.invoke(:scaffold, [table.singularize], {})
      end
      true
    end

    private

    def run_scaffold(class_name)
      type(class_name)
      query(class_name)
      mutation(class_name)
      edge(class_name)
      connection(class_name)
      resolver(class_name)
      rspec_factory(class_name)
      rspec_mutation(class_name)
      rspec_query(class_name)
      rspec_resolver(class_name)
    end


    def generated_paths(class_name)
      singularized_class_name = class_name.singularize.underscore
      pluralized_class_name = class_name.pluralize.underscore
      [
        "./app/models/#{singularized_class_name}.rb",
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
        "./spec/resolvers/#{singularized_class_name}_search_spec.rb"
      ]
    end
  end
end
