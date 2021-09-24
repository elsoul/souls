module Souls
  class Generate < Thor
    desc "mutation_rbs [CLASS_NAME]", "Generate GraphQL Mutation RBS from schema.rb"
    def mutation_rbs(class_name)
      singularized_class_name = class_name.singularize
      create_mutation_head_rbs(singularized_class_name)
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end

    private

    def create_mutation_head_rbs(class_name)
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/types/mutations/base"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        singularized_class_name = class_name.underscore.singularize
        file_path = "#{file_dir}/create_#{singularized_class_name}_rbs.rbs"
        return "Mutation RBS already exist! #{file_path}" if File.exist?(file_path)

        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            class Boolean
            end
            module Mutations
              module Base
                module #{singularized_class_name.camelize}
                  class Create#{singularized_class_name.camelize} < BaseMutation
                    String: String
                    Boolean: Boolean
                    Integer: Integer
                    def resolve:  ({
          TEXT
        end
      end
      file_path
    end

    def create_resolve_params(class_name); end
  end
end
