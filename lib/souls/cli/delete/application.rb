module SOULs
  class Delete < Thor
    desc "scaffold [CLASS_NAME]", "Delete Scaffold"
    def scaffold(class_name)
      singularized_class_name = class_name.singularize
      run_scaffold(class_name: singularized_class_name)
      true
    end

    desc "scaffold_all", "Delete Scaffold All Tables from schema.rb"
    def scaffold_all
      puts(Paint["Delete All Scaffold Files!\n", :cyan])
      SOULs.get_tables.each do |table|
        SOULs::Delete.new.invoke(:scaffold, [table.singularize])
      end
      true
    end

    private

    def run_scaffold(class_name: "user")
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
  end
end
