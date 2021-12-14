module Souls
  class Generate < Thor
    desc "manager_rbs [CLASS_NAME]", "Generate SOULs Manager RBS Template"
    method_option :mutation, aliases: "--mutation", required: true, desc: "Mutation File Name"
    def manager_rbs(class_name)
      file_path = ""
      singularized_class_name = class_name.underscore.singularize
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/mutations/managers/#{singularized_class_name}_manager"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        file_path = "#{file_dir}/#{options[:mutation]}.rbs"
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            module Mutations
              module Managers
                module #{singularized_class_name.camelize}Manager
                  class #{options[:mutation].singularize.camelize}
                    def self.description: (String)-> untyped
                    def self.argument: (untyped, untyped, untyped)-> untyped
                    def self.field: (untyped, untyped, untyped)-> untyped
                  end
                end
              end
            end
          TEXT
          Souls::Painter.create_file(file_path.to_s)
        end
      end
      file_path
    end
  end
end
