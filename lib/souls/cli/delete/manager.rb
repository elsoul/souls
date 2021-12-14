module Souls
  class Delete < Thor
    desc "manager [MANAGER_NAME]", "Delete GraphQL Mutation Template"
    method_option :mutation, aliases: "--mutation", required: true, desc: "Mutation File Name"
    def manager(class_name)
      singularized_class_name = class_name.underscore.singularize
      file_dir = "./app/graphql/mutations/managers/#{singularized_class_name}_manager"
      file_path = "#{file_dir}/#{options[:mutation]}.rb"

      FileUtils.rm_f(file_path)
      Souls::Painter.delete_file(file_path.to_s)
      Souls::Delete.new.invoke(:manager_rbs, [singularized_class_name], { mutation: options[:mutation] })
      Souls::Delete.new.invoke(:rspec_manager, [singularized_class_name], { mutation: options[:mutation] })
      file_path
    end
  end
end
