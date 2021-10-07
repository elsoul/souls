module Souls
  class Delete < Thor
    desc "manager [MANAGER_NAME]", "Delete GraphQL Mutation Template"
    method_option :mutation, aliases: "--mutation", required: true, desc: "Mutation File Name"
    def manager(class_name)
      singularized_class_name = class_name.underscore.singularize
      file_dir = "./app/graphql/mutations/managers/#{singularized_class_name}_manager"
      FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
      file_path = "#{file_dir}/#{options[:mutation]}.rb"

      FileUtils.rm(file_path)
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      Souls::Delete.new.invoke(:manager_rbs, [singularized_class_name], { mutation: options[:mutation] })
      Souls::Delete.new.invoke(:rspec_manager, [singularized_class_name], { mutation: options[:mutation] })
      file_path
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
