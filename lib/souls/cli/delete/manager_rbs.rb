module Souls
  class Delete < Thor
    desc "manager_rbs [CLASS_NAME]", "Delete SOULs Manager RBS Template"
    method_option :mutation, aliases: "--mutation", required: true, desc: "Mutation File Name"
    def manager_rbs(class_name)
      file_path = ""
      singularized_class_name = class_name.underscore.singularize
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/mutations/managers/#{singularized_class_name}_manager"
        file_path = "#{file_dir}/#{options[:mutation]}.rbs"
        FileUtils.rm_f(file_path)
        Souls::Painter.delete_file(file_path.to_s)
      end
      file_path
    end
  end
end
