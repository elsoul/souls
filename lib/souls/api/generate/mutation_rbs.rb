module Souls
  class Generate < Thor
    desc "mutation_rbs [CLASS_NAME]", "Generate GraphQL Mutation RBS from schema.rb"
    def mutation_rbs(class_name)
      file_path = ""
      singularized_class_name = class_name.underscore.singularize
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/mutations/base/#{singularized_class_name}"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        file_path = "#{file_dir}/create_#{singularized_class_name}_rbs.rbs"
        raise(Thor::Error, "Mutation RBS already exist! #{file_path}") if File.exist?(file_path)

        params = Souls.get_relation_params(class_name: class_name)
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
        File.open(file_path, "a") do |f|
          params[:params].each_with_index do |param, i|
            type = Souls.rbs_type_check(param[:type])
            type = "[#{type}]" if param[:array]
            if i == params[:params].size - 1
              f.write("                          #{param[:column_name]}: #{type}?\n")
            else
              f.write("                          #{param[:column_name]}: #{type}?,\n")
            end
          end
        end
        # rubocop:disable Layout/LineLength
        File.open(file_path, "a") do |f|
          f.write("                      }) -> ({ :#{singularized_class_name}_edge => { :node => String } } | ::GraphQL::ExecutionError )\n\n")
        end
        # rubocop:enable Layout/LineLength

        File.open(file_path, "a") do |f|
          params[:params].each_with_index do |param, i|
            type = Souls.type_check(param[:type])
            rbs_type = Souls.rbs_type_check(param[:type])
            type = "[#{type}]" if param[:array]
            if i.zero?
              f.write("        def self.argument: (:#{param[:column_name]}, #{type}, required: false ) -> #{rbs_type}\n")
            else
              f.write("                         | (:#{param[:column_name]}, #{type}, required: false ) -> #{rbs_type}\n")
            end
          end
        end

        File.open(file_path, "a") do |f|
          f.write(<<~TEXT)

                    def self.field: (*untyped) -> String
                    attr_accessor context: {user:{
                      id: Integer,
                      username: String,
                      email: String
                    }}
                  end
                end
              end
            end
          TEXT
        end
      end
      puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      file_path
    rescue Thor::Error => e
      raise(Thor::Error, e)
    end
  end
end
