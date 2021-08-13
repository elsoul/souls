module Souls
  module Api::Generate
    class << self
      def return_method(args)
        graphql_class = args[1]
        class_name = args[2]
        case graphql_class
        when "test_dir"
          Souls::Api::Generate.test_dir
        when "model"
          Souls::Api::Generate.model(class_name: class_name)
        when "mutation"
          Souls::Api::Generate.mutation(class_name: class_name)
        when "query"
          Souls::Api::Generate.query(class_name: class_name)
        when "type"
          Souls::Api::Generate.type(class_name: class_name)
        when "edge"
          Souls::Api::Generate.edge(class_name: class_name)
        when "connection"
          Souls::Api::Generate.connection(class_name: class_name)
        when "resolver"
          Souls::Api::Generate.resolver(class_name: class_name)
        when "policy"
          Souls::Api::Generate.policy(class_name: class_name)
        when "rspec_factory"
          Souls::Api::Generate.rspec_factory(class_name: class_name)
        when "rspec_model"
          Souls::Api::Generate.rspec_model(class_name: class_name)
        when "rspec_mutation"
          Souls::Api::Generate.rspec_mutation(class_name: class_name)
        when "rspec_query"
          Souls::Api::Generate.rspec_query(class_name: class_name)
        when "rspec_resolver"
          Souls::Api::Generate.rspec_resolver(class_name: class_name)
        when "rspec_policy"
          Souls::Api::Generate.rspec_policy(class_name: class_name)
        when "node_type"
          Souls::Api::Generate.node_type(class_name: class_name)
        when "job"
          Souls::Api::Generate.job(class_name: class_name)
        when "migrate"
          Souls::Api::Generate.migrate(class_name: class_name)
        when "migrate_all"
          puts(Paint["Let's Go SOULs AUTO CRUD Assist!\n", :cyan])
          Souls::Api::Generate.get_tables.each do |table|
            Souls::Api::Generate.migrate(class_name: table.singularize)
            puts(Paint["Generated #{table.camelize} CRUD Files\n", :yellow])
          end
        when "migration"
          pluralized_class_name = class_name.underscore.pluralize
          system("rake db:create_migration NAME=create_#{pluralized_class_name}")
        when "update"
          Souls::Api::Generate.update_delete(class_name: class_name)
          Souls::Api::Generate.migrate(class_name: class_name)
        when "worker"
          Souls::Init.download_worker
        else
          "SOULs!"
        end
      end
    end
  end
end
