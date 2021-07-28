module Souls
  module Generate
    class << self
      def return_method(args)
        graphql_class = args[1]
        class_name = args[2]
        case graphql_class
        when "test_dir"
          Souls::Generate.test_dir
        when "model"
          Souls::Generate.model(class_name: class_name)
        when "mutation"
          Souls::Generate.mutation(class_name: class_name)
        when "query"
          Souls::Generate.query(class_name: class_name)
        when "type"
          Souls::Generate.type(class_name: class_name)
        when "edge"
          Souls::Generate.edge(class_name: class_name)
        when "connection"
          Souls::Generate.connection(class_name: class_name)
        when "resolver"
          Souls::Generate.resolver(class_name: class_name)
        when "policy"
          Souls::Generate.policy(class_name: class_name)
        when "rspec_factory"
          Souls::Generate.rspec_factory(class_name: class_name)
        when "rspec_model"
          Souls::Generate.rspec_model(class_name: class_name)
        when "rspec_mutation"
          Souls::Generate.rspec_mutation(class_name: class_name)
        when "rspec_query"
          Souls::Generate.rspec_query(class_name: class_name)
        when "rspec_resolver"
          Souls::Generate.rspec_resolver(class_name: class_name)
        when "rspec_policy"
          Souls::Generate.rspec_policy(class_name: class_name)
        when "node_type"
          Souls::Generate.node_type(class_name: class_name)
        when "job"
          Souls::Generate.job(class_name: class_name)
        when "migrate"
          Souls::Generate.migrate(class_name: class_name)
        when "migrate_all"
          Souls::Generate.migrate_all
        when "migration"
          pluralized_class_name = class_name.underscore.pluralize
          system("rake db:create_migration NAME=create_#{pluralized_class_name}")
        when "update"
          Souls::Generate.update_delete(class_name: class_name)
          Souls::Generate.single_migrate(class_name: class_name)
        else
          "SOULs!"
        end
      end
    end
  end
end
