module Souls
  class Delete < Thor
    desc "scaffold [CLASS_NAME]", "Delete Scaffold"
    method_option :rbs, type: :boolean, aliases: "--rbs", default: false, desc: "Deletes Only RBS Files"
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

    desc "scaffold_all", "Delete Scaffold All Tables from schema.rb"
    method_option :rbs, type: :boolean, aliases: "--rbs", default: false, desc: "Deletes Only RBS Files"
    def scaffold_all
      puts(Paint["Delete All Scaffold Files!\n", :cyan])
      Souls.get_tables.each do |table|
        if options[:rbs]
          Souls::Delete.new.invoke(:scaffold, [table.singularize], { rbs: options[:rbs] })
        else
          Souls::Delete.new.invoke(:scaffold, [table.singularize], {})
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
    end

    def run_rbs_scaffold(class_name: "user")
      type_rbs(class_name)
      query_rbs(class_name)
      mutation_rbs(class_name)
      edge_rbs(class_name)
      connection_rbs(class_name)
      resolver_rbs(class_name)
    end
  end
end
